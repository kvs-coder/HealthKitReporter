//
//  WorkoutConfiguration.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct WorkoutConfiguration: Writable {
    public struct Harmonized: Codable {
        public let activityValue: Int
        public let locationValue: Int
        public let swimmingValue: Int
        public let value: Double
        public let unit: String

        public init(
            activityValue: Int,
            locationValue: Int,
            swimmingValue: Int,
            value: Double,
            unit: String
        ) {
            self.activityValue = activityValue
            self.locationValue = locationValue
            self.swimmingValue = swimmingValue
            self.value = value
            self.unit = unit
        }
    }

    public let harmonized: Harmonized

    init(workoutConfiguration: HKWorkoutConfiguration) throws {
        self.harmonized = try workoutConfiguration.harmonize()
    }

    func asOriginal() throws -> HKWorkoutConfiguration {
        let configuration = HKWorkoutConfiguration()
        if let activityType = HKWorkoutActivityType(rawValue: UInt(harmonized.activityValue)) {
            configuration.activityType = activityType
        }
        if let locationType = HKWorkoutSessionLocationType(rawValue: harmonized.locationValue) {
            configuration.locationType = locationType
        }
        if let swimmingLocationType = HKWorkoutSwimmingLocationType(rawValue: harmonized.swimmingValue) {
            configuration.swimmingLocationType = swimmingLocationType
        }
        configuration.lapLength = HKQuantity(
            unit: HKUnit.init(from: harmonized.unit),
            doubleValue: harmonized.value
        )
        return HKWorkoutConfiguration()
    }
}
