//
//  WorkoutConfiguration.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct WorkoutConfiguration {
    public struct Harmonized: Codable {
        public let value: Double
        public let unit: String

        public init(
            value: Double,
            unit: String
        ) {
            self.value = value
            self.unit = unit
        }
    }

    public let activityValue: Int
    public let locationValue: Int
    public let swimmingValue: Int
    public let harmonized: Harmonized

    public static func make(
        from dictionary: [String: Any]
    ) throws -> WorkoutConfiguration {
        guard
            let activityValue = dictionary["activityValue"] as? Int,
            let locationValue = dictionary["locationValue"] as? Int,
            let swimmingValue = dictionary["swimmingValue"] as? Int,
            let value = dictionary["value"] as? Double,
            let unit = dictionary["unit"] as? String
        else {
            throw HealthKitError.invalidValue(
                "Invalid dictionary: \(dictionary)"
            )
        }
        let harmonized = Harmonized(
            value: value,
            unit: unit
        )
        return WorkoutConfiguration(
            activityValue: activityValue,
            locationValue: locationValue,
            swimmingValue: swimmingValue,
            harmonized: harmonized
        )
    }

    public init(
        activityValue: Int,
        locationValue: Int,
        swimmingValue: Int,
        harmonized: Harmonized
    ) {
        self.activityValue = activityValue
        self.locationValue = locationValue
        self.swimmingValue = swimmingValue
        self.harmonized = harmonized
    }

    init(workoutConfiguration: HKWorkoutConfiguration) throws {
        self.activityValue = Int(workoutConfiguration.activityType.rawValue)
        self.locationValue = workoutConfiguration.locationType.rawValue
        self.swimmingValue = workoutConfiguration.swimmingLocationType.rawValue
        self.harmonized = try workoutConfiguration.harmonize()
    }
}
// MARK: - Original
extension WorkoutConfiguration: Original {
    func asOriginal() throws -> HKWorkoutConfiguration {
        let configuration = HKWorkoutConfiguration()
        if let activityType = HKWorkoutActivityType(rawValue: UInt(activityValue)) {
            configuration.activityType = activityType
        }
        if let locationType = HKWorkoutSessionLocationType(rawValue: locationValue) {
            configuration.locationType = locationType
        }
        if let swimmingLocationType = HKWorkoutSwimmingLocationType(rawValue: swimmingValue) {
            configuration.swimmingLocationType = swimmingLocationType
        }
        configuration.lapLength = HKQuantity(
            unit: HKUnit.init(from: harmonized.unit),
            doubleValue: harmonized.value
        )
        return HKWorkoutConfiguration()
    }
}
