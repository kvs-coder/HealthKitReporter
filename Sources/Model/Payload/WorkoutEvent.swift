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

        public func copyWith(
            value: Int? = nil,
            metadata: [String: String]? = nil
        ) -> Harmonized {
            return Harmonized(
                value: value ?? self.value,
                metadata: metadata ?? self.metadata
            )
        }
    }

    public let type: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let duration: Double
    public let harmonized: Harmonized

    @available(iOS 11.0, *)
    init(workoutEvent: HKWorkoutEvent) throws {
        self.type = workoutEvent.type.name
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

    public func copyWith(
        type: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        duration: Double? = nil,
        harmonized: Harmonized? = nil
    ) -> WorkoutEvent {
        return WorkoutEvent(
            type: type ?? self.type,
            startTimestamp: startTimestamp ?? self.startTimestamp,
            endTimestamp: endTimestamp ?? self.endTimestamp,
            duration: duration ?? self.duration,
            harmonized: harmonized ?? self.harmonized
        )
    }
}
// MARK: - Original
extension WorkoutEvent: Original {
    func asOriginal() throws -> HKWorkoutEvent {
        guard #available(iOS 11.0, *) else {
            throw HealthKitError.notAvailable(
                "HKWorkoutEvent DateInterval is not available for the current iOS"
            )
        }
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
        let metadata = dictionary["metadata"] as? [String: String]
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
            let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
            let endTimestamp = dictionary["endTimestamp"] as? NSNumber,
            let duration = dictionary["duration"] as? NSNumber,
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return WorkoutEvent(
            type: type,
            startTimestamp: Double(truncating: startTimestamp).secondsSince1970,
            endTimestamp: Double(truncating: endTimestamp).secondsSince1970,
            duration: Double(truncating: duration),
            harmonized: try WorkoutEvent.Harmonized.make(from: harmonized)
        )
    }
}
