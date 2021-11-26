//
//  WorkoutEvent.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

@objc(HKRWorkoutEvent)
public final class WorkoutEvent: NSObject, Sample {
    @objcMembers
    public final class Harmonized: NSObject, Codable {
        public let value: Int
        public let name: String
        public let metadata: [String: String]?

        public init(value: Int, name: String, metadata: [String: String]?) {
            self.value = value
            self.name = name
            self.metadata = metadata
        }

        public func copyWith(
            value: Int? = nil,
            name: String? = nil,
            metadata: [String: String]? = nil
        ) -> Harmonized {
            return Harmonized(
                value: value ?? self.value,
                name: name ?? self.name,
                metadata: metadata ?? self.metadata
            )
        }
    }

    @objc
    public let startTimestamp: Double
    @objc
    public let endTimestamp: Double
    @objc
    public let duration: Double
    @objc
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

    @objc
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
            metadata: harmonized.metadata
        )
    }
}
// MARK: - Payload
extension WorkoutEvent.Harmonized: Payload {
    @objc
    public static func make(
        from dictionary: [String: Any]
    ) throws ->  WorkoutEvent.Harmonized {
        guard
            let value = dictionary["value"] as? Int,
            let name = dictionary["name"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: String]
        return  WorkoutEvent.Harmonized(
            value: value,
            name: name,
            metadata: metadata
        )
    }
}
// MARK: - Payload
extension WorkoutEvent: Payload {
    @objc
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
