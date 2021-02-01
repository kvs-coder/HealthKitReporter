//
//  WorkoutEvent.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct WorkoutEvent: Sample {
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
}
// MARK: - Original
extension WorkoutEvent: Original {
    func asOriginal() throws -> HKWorkoutEvent {
        guard let type = HKWorkoutEventType(rawValue: harmonized.value) else {
            throw HealthKitError.invalidType(
                "WorkoutEvent type: \(harmonized.value) could not be formatted"
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
// MARK: - Payload
extension WorkoutEvent.Harmonized: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws ->  WorkoutEvent.Harmonized {
        guard let value = dictionary["value"] as? Int else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["value"] as? [String: String]
        return  WorkoutEvent.Harmonized(value: value, metadata: metadata)
    }
}
// MARK: - Payload
extension WorkoutEvent: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws -> WorkoutEvent {
        guard
            let type = dictionary["type"] as? String,
            let startTimestamp = dictionary["startTimestamp"] as? Double,
            let endTimestamp = dictionary["endTimestamp"] as? Double,
            let duration = dictionary["duration"] as? Double,
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return WorkoutEvent(
            type: type,
            startTimestamp: startTimestamp.secondsSince1970,
            endTimestamp: endTimestamp.secondsSince1970,
            duration: duration,
            harmonized: try WorkoutEvent.Harmonized.make(from: harmonized)
        )
    }
}
