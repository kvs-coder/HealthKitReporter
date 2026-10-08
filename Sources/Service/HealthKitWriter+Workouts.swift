//
//  HealthKitWriter+Workouts.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit
import CoreLocation

// MARK: - Workouts
extension HealthKitWriter {
    /**
     Saves a workout through **HKWorkoutBuilder**, which replaces the deprecated HKWorkout initializer.
     The harmonized totals are added as samples for the types **samples** doesn't already contain.
     - Parameter workout: **Workout** workout; its activities are added on iOS 16+,
     and the first one's location, swimming location and lap length configure the builder
     - Parameter samples: **Quantity** samples recorded during the workout (optional)
     - Parameter route: **WorkoutRoute.Location** locations of the route (optional)
     - Parameter completion: returns a block with the saved workout. The workout is saved even when its route
     fails; then the block carries both the workout and the route's error
     */
    public func saveWorkout(
        _ workout: Workout,
        samples: [Quantity] = [],
        route: [WorkoutRoute.Location] = [],
        completion: @escaping WorkoutSaveCompletion
    ) {
        do {
            let builder = try workoutBuilder(for: workout)
            let steps = try workoutSteps(for: workout, samples: samples, builder: builder)
            run(steps[...]) { success, error in
                guard success else {
                    completion(nil, error)
                    return
                }
                builder.finishWorkout { hkWorkout, error in
                    guard let hkWorkout = hkWorkout else {
                        completion(nil, error)
                        return
                    }
                    self.saveRoute(route, of: hkWorkout, device: workout.device) { routeError in
                        do {
                            completion(try Workout(workout: hkWorkout), routeError)
                        } catch {
                            completion(nil, error)
                        }
                    }
                }
            }
        } catch {
            completion(nil, error)
        }
    }

    private func workoutBuilder(for workout: Workout) throws -> HKWorkoutBuilder {
        guard let activityType = HKWorkoutActivityType(knownRawValue: workout.harmonized.value) else {
            throw HealthKitError.invalidType(
                "Workout type: \(workout.harmonized.value) could not be formatted"
            )
        }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        if #available(iOS 16.0, watchOS 9.0, *), let activity = workout.activities?.first {
            activity.configure(configuration)
        }
        return HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: configuration,
            device: workout.device?.asOriginal()
        )
    }
    /// Each builder call waits for the previous one; the totals become samples spanning the workout
    private func workoutSteps(
        for workout: Workout,
        samples: [Quantity],
        builder: HKWorkoutBuilder
    ) throws -> [(@escaping StatusCompletionBlock) -> Void] {
        let start = workout.startTimestamp.asDate
        let end = workout.endTimestamp.asDate
        let recorded = Set(samples.map(\.identifier))
        let totals = try workout.totalSamples().filter { !recorded.contains($0.quantityType.identifier) }
        let hkSamples: [HKSample] = try samples.map { try $0.asOriginal() } + totals
        let events = try workout.workoutEvents.map { try $0.asOriginal() }
        let metadata = try workout.harmonized.metadata?.asOriginal()
        var steps: [(@escaping StatusCompletionBlock) -> Void] = [
            { builder.beginCollection(withStart: start, completion: $0) }
        ]
        if !hkSamples.isEmpty {
            steps.append { builder.add(hkSamples, completion: $0) }
        }
        if !events.isEmpty {
            steps.append { builder.addWorkoutEvents(events, completion: $0) }
        }
        if let metadata = metadata {
            steps.append { builder.addMetadata(metadata, completion: $0) }
        }
        if #available(iOS 16.0, watchOS 9.0, *) {
            for activity in try (workout.activities ?? []).map({ try $0.asOriginal() }) {
                steps.append { builder.addWorkoutActivity(activity, completion: $0) }
            }
        }
        steps.append { builder.endCollection(withEnd: end, completion: $0) }
        return steps
    }
    private func run(
        _ steps: ArraySlice<(@escaping StatusCompletionBlock) -> Void>,
        completion: @escaping StatusCompletionBlock
    ) {
        guard let step = steps.first else {
            completion(true, nil)
            return
        }
        step { success, error in
            guard success else {
                completion(false, error)
                return
            }
            self.run(steps.dropFirst(), completion: completion)
        }
    }
    private func saveRoute(
        _ route: [WorkoutRoute.Location],
        of workout: HKWorkout,
        device: Device?,
        completion: @escaping (Error?) -> Void
    ) {
        guard !route.isEmpty else {
            completion(nil)
            return
        }
        let builder = HKWorkoutRouteBuilder(healthStore: healthStore, device: device?.asOriginal())
        builder.insertRouteData(route.map(\.asOriginal)) { success, error in
            guard success else {
                completion(error)
                return
            }
            builder.finishRoute(with: workout, metadata: nil) { _, error in
                completion(error)
            }
        }
    }
}
// MARK: - Workout effort
@available(iOS 18.0, watchOS 11.0, *)
extension HealthKitWriter {
    /**
     Relates a workout effort score sample to a stored workout, or to one of its activities.
     A sample already stored in HealthKit is looked up by its uuid; a new sample is saved by the relation
     - Parameter sample: **Quantity** workout effort score or estimated workout effort score
     - Parameter workoutUUID: **String** uuid of the stored workout
     - Parameter activityUUID: **String** uuid of one of the workout's activities (optional)
     - Parameter completion: block notifies about operation status
     */
    public func relateWorkoutEffort(
        _ sample: Quantity,
        toWorkout workoutUUID: String,
        activity activityUUID: String? = nil,
        completion: @escaping StatusCompletionBlock
    ) {
        effortRelation(
            sample,
            storedOnly: false,
            workout: (workoutUUID, activityUUID),
            completion: completion
        ) {
            self.healthStore.relateWorkoutEffortSample($0, with: $1, activity: $2, completion: completion)
        }
    }
    /**
     Removes the relation between a workout effort score sample and a stored workout.
     - Parameter sample: **Quantity** stored workout effort score or estimated workout effort score,
     looked up by its uuid
     - Parameter workoutUUID: **String** uuid of the stored workout
     - Parameter activityUUID: **String** uuid of one of the workout's activities (optional)
     - Parameter completion: block notifies about operation status
     */
    public func unrelateWorkoutEffort(
        _ sample: Quantity,
        fromWorkout workoutUUID: String,
        activity activityUUID: String? = nil,
        completion: @escaping StatusCompletionBlock
    ) {
        effortRelation(
            sample,
            storedOnly: true,
            workout: (workoutUUID, activityUUID),
            completion: completion
        ) {
            self.healthStore.unrelateWorkoutEffortSample($0, from: $1, activity: $2, completion: completion)
        }
    }

    private func effortRelation(
        _ sample: Quantity,
        storedOnly: Bool,
        workout target: (uuid: String, activity: String?),
        completion: @escaping StatusCompletionBlock,
        relate: @escaping (HKSample, HKWorkout, HKWorkoutActivity?) -> Void
    ) {
        let effortTypes: [QuantityType] = [.workoutEffortScore, .estimatedWorkoutEffortScore]
        guard let effortType = effortTypes.first(where: { $0.identifier == sample.identifier }) else {
            completion(
                false,
                HealthKitError.invalidType("\(sample.identifier) is not a workout effort score")
            )
            return
        }
        effortSample(sample, of: effortType, storedOnly: storedOnly) { [healthStore] hkSample, error in
            guard let hkSample = hkSample else {
                completion(false, error)
                return
            }
            healthStore.storedSample(of: WorkoutType.workoutType, uuid: target.uuid) { workout, error in
                guard let workout = workout as? HKWorkout else {
                    completion(false, error)
                    return
                }
                let activity = workout.workoutActivities.first { $0.uuid.uuidString == target.activity }
                guard target.activity == nil || activity != nil else {
                    completion(
                        false,
                        HealthKitError.invalidIdentifier("No activity \(target.activity ?? "")")
                    )
                    return
                }
                relate(hkSample, workout, activity)
            }
        }
    }

    private func effortSample(
        _ sample: Quantity,
        of type: QuantityType,
        storedOnly: Bool,
        completion: @escaping (HKSample?, Error?) -> Void
    ) {
        healthStore.storedSample(of: type, uuid: sample.uuid) { stored, error in
            guard stored == nil, !storedOnly else {
                completion(stored, error)
                return
            }
            do {
                completion(try sample.asOriginal(), nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
