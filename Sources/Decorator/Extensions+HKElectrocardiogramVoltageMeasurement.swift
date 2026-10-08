//
//  Extensions+HKElectrocardiogramVoltageMeasurement.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import HealthKit

// MARK: - Harmonizable
extension HKElectrocardiogram.VoltageMeasurement: Harmonizable {
    typealias Harmonized = Electrocardiogram.VoltageMeasurement.Harmonized

    func harmonize() throws -> Harmonized {
        guard
            let quantity = quantity(for: .appleWatchSimilarToLeadI)
        else {
            throw HealthKitError.invalidValue(
                "No Apple Watch lead I voltage in HKElectrocardiogram.VoltageMeasurement"
            )
        }
        let unit = HKUnit.volt()
        let voltage = quantity.doubleValue(for: unit)
        return Harmonized(value: voltage, unit: unit.unitString)
    }
}
