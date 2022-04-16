//
//  WorkoutConfiguration.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

@available(iOS 10.0, *)
public struct WorkoutConfiguration: Codable {
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
@available(iOS 10.0, *)
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
// MARK: - Payload
@available(iOS 10.0, *)
extension WorkoutConfiguration.Harmonized: Payload {
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
