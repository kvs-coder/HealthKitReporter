//
//  WorkoutConfiguration.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

public struct WorkoutConfiguration: Writable {
    public let harmonized: HKWorkoutConfiguration.Harmonized

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
