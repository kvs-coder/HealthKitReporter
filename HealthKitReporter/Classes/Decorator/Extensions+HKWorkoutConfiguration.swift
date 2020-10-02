//
//  Extensions+HKWorkoutConfiguration.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

extension HKWorkoutConfiguration: Harmonizable {
    typealias Harmonized = WorkoutConfiguration.Harmonized

    func harmonize() throws -> Harmonized {
        let unit = HKUnit.meter()
        guard let value = self.lapLength?.doubleValue(for: unit) else {
            throw HealthKitError.invalidValue("Value for HKWorkoutConfiguration is invalid")
        }
        return Harmonized(
            activityValue: Int(self.activityType.rawValue),
            locationValue: self.locationType.rawValue,
            swimmingValue: self.swimmingLocationType.rawValue,
            value: value,
            unit: unit.unitString
        )
    }
}
