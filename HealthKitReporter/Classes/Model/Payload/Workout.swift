//
//  Workout.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Workout: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let value: Int
        public let totalEnergyBurned: Double?
        public let totalEnergyBurnedUnit: String
        public let totalDistance: Double?
        public let totalDistanceUnit: String
        public let totalSwimmingStrokeCount: Double?
        public let totalSwimmingStrokeCountUnit: String
        public let totalFlightsClimbed: Double?
        public let totalFlightsClimbedUnit: String
        public let metadata: [String: String]?

        public init(
            value: Int,
            totalEnergyBurned: Double?,
            totalEnergyBurnedUnit: String,
            totalDistance: Double?,
            totalDistanceUnit: String,
            totalSwimmingStrokeCount: Double?,
            totalSwimmingStrokeCountUnit: String,
            totalFlightsClimbed: Double?,
            totalFlightsClimbedUnit: String,
            metadata: [String: String]?
        ) {
            self.value = value
            self.totalEnergyBurned = totalEnergyBurned
            self.totalEnergyBurnedUnit = totalEnergyBurnedUnit
            self.totalDistance = totalDistance
            self.totalDistanceUnit = totalDistanceUnit
            self.totalSwimmingStrokeCount = totalSwimmingStrokeCount
            self.totalSwimmingStrokeCountUnit = totalSwimmingStrokeCountUnit
            self.totalFlightsClimbed = totalFlightsClimbed
            self.totalFlightsClimbedUnit = totalFlightsClimbedUnit
            self.metadata = metadata
        }
    }

    public let uuid: String
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let workoutName: String
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let duration: Double
    public let workoutEvents: [WorkoutEvent]
    public let harmonized: Harmonized

    public static func collect(
        results: [HKSample]
    ) -> [Workout] {
        var samples = [Workout]()
        if let workouts = results as? [HKWorkout] {
            for workout in workouts {
                do {
                    let sample = try Workout(
                        workout: workout
                    )
                    samples.append(sample)
                } catch {
                    continue
                }
            }
        }
        return samples
    }

    init(workout: HKWorkout) throws {
        self.uuid = workout.uuid.uuidString
        self.identifier = workout.sampleType.identifier
        self.startTimestamp = workout.startDate.timeIntervalSince1970
        self.endTimestamp = workout.endDate.timeIntervalSince1970
        self.device = Device(device: workout.device)
        self.sourceRevision = SourceRevision(sourceRevision: workout.sourceRevision)
        self.workoutName = String(describing: workout.workoutActivityType)
        self.duration = workout.duration
        var workoutEvents = [WorkoutEvent]()
        if let events = workout.workoutEvents {
            for element in events {
                do {
                    let workoutEvent = try WorkoutEvent(workoutEvent: element)
                    workoutEvents.append(workoutEvent)
                } catch {
                    continue
                }
            }
        }
        self.workoutEvents = workoutEvents
        self.harmonized = try workout.harmonize()
    }

    public init(
        uuid: String,
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        workoutName: String,
        device: Device?,
        sourceRevision: SourceRevision,
        duration: Double,
        workoutEvents: [WorkoutEvent],
        harmonized: Harmonized
    ) {
        self.uuid = uuid
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.workoutName = workoutName
        self.device = device
        self.sourceRevision = sourceRevision
        self.duration = duration
        self.workoutEvents = workoutEvents
        self.harmonized = harmonized
    }
}
// MARK: - Original
extension Workout: Original {
    func asOriginal() throws -> HKWorkout {
        guard let activityType = HKWorkoutActivityType(rawValue: UInt(harmonized.value)) else {
            throw HealthKitError.invalidType(
                "Workout type: \(harmonized.value) could not be formatted"
            )
        }
        return HKWorkout(
            activityType: activityType,
            start: startTimestamp.asDate,
            end: endTimestamp.asDate,
            workoutEvents: try workoutEvents.map({ try $0.asOriginal() }),
            totalEnergyBurned: harmonized.totalEnergyBurned != nil
                ? HKQuantity(
                    unit: HKUnit.init(from: harmonized.totalEnergyBurnedUnit),
                    doubleValue: harmonized.totalEnergyBurned!
                )
                : nil,
            totalDistance: harmonized.totalDistance != nil
                ? HKQuantity(
                    unit: HKUnit.init(from: harmonized.totalDistanceUnit),
                    doubleValue: harmonized.totalDistance!
                )
                : nil,
            totalSwimmingStrokeCount: harmonized.totalSwimmingStrokeCount != nil
                ? HKQuantity(
                    unit: HKUnit.init(from: harmonized.totalSwimmingStrokeCountUnit),
                    doubleValue: harmonized.totalSwimmingStrokeCount!
                )
                : nil,
            device: device?.asOriginal(),
            metadata: harmonized.metadata
        )
    }
}
// MARK: - Payload
extension Workout: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws -> Workout {
        guard
            let uuid = dictionary["uuid"] as? String,
            let identifier = dictionary["identifier"] as? String,
            let startTimestamp = dictionary["startTimestamp"] as? Double,
            let endTimestamp = dictionary["endTimestamp"] as? Double,
            let workoutName = dictionary["workoutName"] as? String,
            let duration = dictionary["duration"] as? Double,
            let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let device = dictionary["device"] as? [String: Any]
        let workoutEvents = dictionary["workoutEvents"] as? [[String: Any]]
        return Workout(
            uuid: uuid,
            identifier: identifier,
            startTimestamp: startTimestamp.secondsSince1970,
            endTimestamp: endTimestamp.secondsSince1970,
            workoutName: workoutName,
            device: device != nil
                ? try Device.make(from: device!)
                : nil,
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            duration: duration,
            workoutEvents: workoutEvents != nil
                ? try workoutEvents!.map {
                    try WorkoutEvent.make(from: $0)
                }
                : [],
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
// MARK: - Payload
extension Workout.Harmonized: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws -> Workout.Harmonized {
        guard
            let value = dictionary["value"] as? Int,
            let totalEnergyBurnedUnit = dictionary["totalEnergyBurnedUnit"] as? String,
            let totalDistanceUnit = dictionary["totalDistanceUnit"] as? String,
            let totalSwimmingStrokeCountUnit = dictionary["totalSwimmingStrokeCountUnit"] as? String,
            let totalFlightsClimbedUnit = dictionary["totalFlightsClimbedUnit"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let totalEnergyBurned = dictionary["totalEnergyBurned"] as? Double
        let totalDistance = dictionary["totalDistance"] as? Double
        let totalSwimmingStrokeCount = dictionary["totalSwimmingStrokeCount"] as? Double
        let totalFlightsClimbed = dictionary["totalFlightsClimbed"] as? Double
        let metadata = dictionary["metadata"] as? [String: String]
        return Workout.Harmonized(
            value: value,
            totalEnergyBurned: totalEnergyBurned,
            totalEnergyBurnedUnit: totalEnergyBurnedUnit,
            totalDistance: totalDistance,
            totalDistanceUnit: totalDistanceUnit,
            totalSwimmingStrokeCount: totalSwimmingStrokeCount,
            totalSwimmingStrokeCountUnit: totalSwimmingStrokeCountUnit,
            totalFlightsClimbed: totalFlightsClimbed,
            totalFlightsClimbedUnit: totalFlightsClimbedUnit,
            metadata: metadata
        )
    }
}
