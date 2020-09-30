//
//  Workout.swift
//  HealthKitReporter
//
//  Created by KVS on 25.09.20.
//

import Foundation
import HealthKit

public struct Workout: Identifiable, Sample, Writable {
    public let identifier: String
    public let startDate: String
    public let endDate: String
    public let workoutName: String
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let duration: Double
    public let workoutEvents: [WorkoutEvent]
    public let harmonized: HKWorkout.Harmonized

    public init(workout: HKWorkout) throws {
        self.identifier = workout.sampleType.identifier
        self.startDate = workout.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = workout.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
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
        guard
            let start = startDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ),
            let end = endDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ)
        else {
            throw HealthKitError.invalidValue(
                "Category start: \(startDate) and end: \(endDate) could not be formatted"
            )
        }
        return HKWorkout(
            activityType: activityType,
            start: start,
            end: end,
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
