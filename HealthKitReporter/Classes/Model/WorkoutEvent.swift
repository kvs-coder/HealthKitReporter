//
//  WorkoutEvent.swift
//  HealthKitReporter
//
//  Created by KVS on 25.09.20.
//

import Foundation
import HealthKit

public struct WorkoutEvent: Sample, Writable {
    public let type: String
    public let startDate: String
    public let endDate: String
    public let duration: Double
    public let harmonized: HKWorkoutEvent.Harmonized

    public init(workoutEvent: HKWorkoutEvent) throws {
        self.type = String(describing: workoutEvent.type)
        self.startDate = workoutEvent
            .dateInterval
            .start
            .formatted(with: Date.yyyyMMddTHHmmssZZZZZ)
        self.endDate = workoutEvent
            .dateInterval
            .end
            .formatted(with: Date.yyyyMMddTHHmmssZZZZZ)
        self.duration = workoutEvent.dateInterval.duration
        self.harmonized = try workoutEvent.harmonize()
    }

    func asOriginal() throws -> HKWorkoutEvent {
        guard let type = HKWorkoutEventType(rawValue: harmonized.value) else {
            throw HealthKitError.invalidType(
                "WorkoutEvent type: \(harmonized.value) could not be foramtted"
            )
        }
        guard
            let start = startDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ),
            let end = endDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ)
        else {
            throw HealthKitError.invalidValue(
                "WorkoutEvent start: \(startDate) and end: \(endDate) could not be formatted"
            )
        }
        return HKWorkoutEvent(
            type: type,
            dateInterval: DateInterval(start: start, end: end),
            metadata: harmonized.metadata
        )
    }
}
