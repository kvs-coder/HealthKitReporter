//
//  Extensions+HKWorkoutConfiguration.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

@available(iOS 10.0, *)
extension HKWorkoutConfiguration: Harmonizable {
    typealias Harmonized = WorkoutConfiguration.Harmonized

    func harmonize() throws -> Harmonized {
        let unit = HKUnit.meter()
        guard let value = lapLength?.doubleValue(for: unit) else {
            throw HealthKitError.invalidValue("Value for HKWorkoutConfiguration is invalid")
        }
        return Harmonized(
            value: value,
            unit: unit.unitString
        )
    }
}
