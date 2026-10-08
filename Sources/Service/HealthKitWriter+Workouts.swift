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
     - Parameter workout: **Workout** workout; its activities are added on iOS 16+
     - Parameter samples: **Quantity** samples recorded during the workout (optional)
     - Parameter route: **WorkoutRoute.Location** locations of the route (optional)
     - Parameter completion: returns a block with the saved workout
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
                    self.saveRoute(route, of: hkWorkout, device: workout.device) { error in
                        completion(try? Workout(workout: hkWorkout), error)
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
        effortRelation(sample, workoutUUID: workoutUUID, activityUUID: activityUUID, completion: completion) {
            self.healthStore.relateWorkoutEffortSample($0, with: $1, activity: $2, completion: completion)
        }
    }
    /**
     Removes the relation between a workout effort score sample and a stored workout.
     - Parameter sample: **Quantity** workout effort score or estimated workout effort score
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
        effortRelation(sample, workoutUUID: workoutUUID, activityUUID: activityUUID, completion: completion) {
            self.healthStore.unrelateWorkoutEffortSample($0, from: $1, activity: $2, completion: completion)
        }
    }

    private func effortRelation(
        _ sample: Quantity,
        workoutUUID: String,
        activityUUID: String?,
        completion: @escaping StatusCompletionBlock,
        relate: @escaping (HKQuantitySample, HKWorkout, HKWorkoutActivity?) -> Void
    ) {
        let effortTypes: [QuantityType] = [.workoutEffortScore, .estimatedWorkoutEffortScore]
        guard effortTypes.contains(where: { $0.identifier == sample.identifier }) else {
            completion(
                false,
                HealthKitError.invalidType("\(sample.identifier) is not a workout effort score")
            )
            return
        }
        let hkSample: HKQuantitySample
        do {
            hkSample = try sample.asOriginal()
        } catch {
            completion(false, error)
            return
        }
        healthStore.storedSample(of: WorkoutType.workoutType, uuid: workoutUUID) { workout, error in
            guard let workout = workout as? HKWorkout else {
                completion(false, error)
                return
            }
            let activity = workout.workoutActivities.first { $0.uuid.uuidString == activityUUID }
            guard activityUUID == nil || activity != nil else {
                completion(false, HealthKitError.invalidIdentifier("No activity \(activityUUID ?? "")"))
                return
            }
            relate(hkSample, workout, activity)
        }
    }
}
