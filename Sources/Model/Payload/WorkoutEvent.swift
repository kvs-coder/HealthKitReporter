//
//  WorkoutEvent.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

public struct WorkoutEvent: Sample {
    public struct Harmonized: Codable {
        public let value: Int
        public let description: String
        public let metadata: Metadata?

        public init(value: Int, description: String, metadata: Metadata?) {
            self.value = value
            self.description = description
            self.metadata = metadata
        }

        public func copyWith(
            value: Int? = nil,
            description: String? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                value: value ?? self.value,
                description: description ?? self.description,
                metadata: metadata ?? self.metadata
            )
        }
    }

    public let startTimestamp: Double
    public let endTimestamp: Double
    public let duration: Double
    public let harmonized: Harmonized

    @available(iOS 11.0, *)
    init(workoutEvent: HKWorkoutEvent) throws {
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
        startTimestamp: Double,
        endTimestamp: Double,
        duration: Double,
        harmonized: Harmonized
    ) {
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.duration = duration
        self.harmonized = harmonized
    }

    public func copyWith(
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        duration: Double? = nil,
        harmonized: Harmonized? = nil
    ) -> WorkoutEvent {
        return WorkoutEvent(
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
            metadata: harmonized.metadata?.original
        )
    }
}
// MARK: - Payload
extension WorkoutEvent.Harmonized: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws ->  WorkoutEvent.Harmonized {
        guard
            let value = dictionary["value"] as? Int,
            let description = dictionary["description"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return WorkoutEvent.Harmonized(
            value: value,
            description: description,
            metadata: metadata?.asMetadata
        )
    }
}
// MARK: - Payload
extension WorkoutEvent: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws -> WorkoutEvent {
        guard
            let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
            let endTimestamp = dictionary["endTimestamp"] as? NSNumber,
            let duration = dictionary["duration"] as? NSNumber,
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return WorkoutEvent(
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: Double(truncating: endTimestamp),
            duration: Double(truncating: duration),
            harmonized: try WorkoutEvent.Harmonized.make(from: harmonized)
        )
    }
}
