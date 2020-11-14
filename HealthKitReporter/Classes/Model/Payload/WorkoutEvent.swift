//
//  WorkoutEvent.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct WorkoutEvent: Sample, Original {
    public struct Harmonized: Codable {
        public let value: Int
        public let metadata: [String: String]?

        public init(value: Int, metadata: [String: String]?) {
            self.value = value
            self.metadata = metadata
        }
    }

    public let type: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let duration: Double
    public let harmonized: Harmonized

    init(workoutEvent: HKWorkoutEvent) throws {
        self.type = String(describing: workoutEvent.type)
        self.startTimestamp = workoutEvent
            .dateInterval
            .start
            .timeIntervalSince1970
        self.endTimestamp = workoutEvent
            .dateInterval
            .end
            .timeIntervalSince1970
        self.duration = workoutEvent.dateInterval.duration
        self.harmonized = try workoutEvent.harmonize()
    }

    public init(
        type: String,
        startTimestamp: Double,
        endTimestamp: Double,
        duration: Double,
        harmonized: Harmonized
    ) {
        self.type = type
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.duration = duration
        self.harmonized = harmonized
    }

    func asOriginal() throws -> HKWorkoutEvent {
        guard let type = HKWorkoutEventType(rawValue: harmonized.value) else {
            throw HealthKitError.invalidType(
                "WorkoutEvent type: \(harmonized.value) could not be foramtted"
            )
        }
        return HKWorkoutEvent(
            type: type,
            dateInterval: DateInterval(
                start: startTimestamp.asDate,
                end: endTimestamp.asDate
            ),
            metadata: harmonized.metadata
        )
    }
}
