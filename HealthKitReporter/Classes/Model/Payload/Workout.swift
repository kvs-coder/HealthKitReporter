//
//  Workout.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Workout: Identifiable, Sample, Original {
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

    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let workoutName: String
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let duration: Double
    public let workoutEvents: [WorkoutEvent]
    public let harmonized: Harmonized

    public init(workout: HKWorkout) throws {
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

    func asOriginal() throws -> HKWorkout {
        guard let activityType = HKWorkoutActivityType(rawValue: UInt(harmonized.value)) else {
            throw HealthKitError.invalidType(
                "Workout type: \(harmonized.value) could not be foramtted"
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
