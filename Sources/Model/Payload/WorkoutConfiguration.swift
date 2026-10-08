//
//  WorkoutConfiguration.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

/// **WorkoutConfiguration** the activity, location and lap length a watch workout starts with
public struct WorkoutConfiguration: Codable {
    /// The value part of **WorkoutConfiguration**
    public struct Harmonized: Codable {
        public let value: Double
        public let unit: String

        /// Creates the **Harmonized** from its fields
        public init(
            value: Double,
            unit: String
        ) {
            self.value = value
            self.unit = unit
        }

        /// A copy with the given fields replaced; nil keeps the current value
        public func copyWith(
            value: Double? = nil,
            unit: String? = nil
        ) -> Harmonized {
            return Harmonized(
                value: value ?? self.value,
                unit: unit ?? self.unit
            )
        }
    }

    public let activityValue: Int
    public let locationValue: Int
    public let swimmingValue: Int
    public let harmonized: Harmonized

    /// Creates the **WorkoutConfiguration** from its fields
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

    /// A copy with the given fields replaced; nil keeps the current value
    public func copyWith(
        activityValue: Int? = nil,
        locationValue: Int? = nil,
        swimmingValue: Int? = nil,
        harmonized: Harmonized? = nil
    ) -> WorkoutConfiguration {
        return WorkoutConfiguration(
            activityValue: activityValue ?? self.activityValue,
            locationValue: locationValue ?? self.locationValue,
            swimmingValue: swimmingValue ?? self.swimmingValue,
            harmonized: harmonized ?? self.harmonized
        )
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
        guard let activityType = HKWorkoutActivityType(knownRawValue: activityValue) else {
            throw HealthKitError.invalidType("Workout activity type: \(activityValue) could not be formatted")
        }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        if let locationType = HKWorkoutSessionLocationType(knownRawValue: locationValue) {
            configuration.locationType = locationType
        }
        if let swimmingLocationType = HKWorkoutSwimmingLocationType(knownRawValue: swimmingValue) {
            configuration.swimmingLocationType = swimmingLocationType
        }
        configuration.lapLength = HKQuantity(
            unit: try HKQuantityType(.distanceSwimming).compatibleUnit(from: harmonized.unit),
            doubleValue: harmonized.value
        )
        return configuration
    }
}
// MARK: - Payload
extension WorkoutConfiguration: Payload {
    /**
     Makes a **WorkoutConfiguration** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(
        from dictionary: [String: Any]
    ) throws -> WorkoutConfiguration {
        guard
            let activityValue = dictionary.int("activityValue"),
            let locationValue = dictionary.int("locationValue"),
            let swimmingValue = dictionary.int("swimmingValue"),
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue(
                "Invalid dictionary: \(dictionary)"
            )
        }
        return WorkoutConfiguration(
            activityValue: activityValue,
            locationValue: locationValue,
            swimmingValue: swimmingValue,
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
// MARK: - Payload
extension WorkoutConfiguration.Harmonized: Payload {
    /**
     Makes a **WorkoutConfiguration.Harmonized** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(
        from dictionary: [String: Any]
    ) throws -> WorkoutConfiguration.Harmonized {
        guard
            let value = dictionary["value"] as? NSNumber,
            let unit = dictionary["unit"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return WorkoutConfiguration.Harmonized(
            value: Double(truncating: value),
            unit: unit
        )
    }
}
