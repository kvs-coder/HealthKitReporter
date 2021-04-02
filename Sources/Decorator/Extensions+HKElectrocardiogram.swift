//
//  Extensions+HKElectrocardiogram.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import Foundation
import HealthKit

@available(iOS 14.0, *)
extension HKElectrocardiogram: Harmonizable {
    typealias Harmonized = Electrocardiogram.Harmonized

    func harmonize() throws -> Harmonized {
        let averageHeartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        guard
            let averageHeartRate = averageHeartRate?.doubleValue(for: averageHeartRateUnit)
        else {
            throw HealthKitError.invalidValue(
                "Invalid averageHeartRate value for HKElectrocardiogram"
            )
        }
        let samplingFrequencyUnit = HKUnit.hertz()
        guard
            let samplingFrequency = samplingFrequency?.doubleValue(for: samplingFrequencyUnit)
        else {
            throw HealthKitError.invalidValue(
                "Invalid samplingFrequency value for HKElectrocardiogram"
            )
        }
        let classification = String(describing: self.classification)
        let symptomsStatus = String(describing: self.symptomsStatus)
        return Harmonized(
            averageHeartRate: averageHeartRate,
            averageHeartRateUnit: averageHeartRateUnit.unitString,
            samplingFrequency: samplingFrequency,
            samplingFrequencyUnit: samplingFrequencyUnit.unitString,
            classification: classification,
            symptomsStatus: symptomsStatus,
            metadata: metadata?.compactMapValues { String(describing: $0 )}
        )
    }
}

@available(iOS 14.0, *)
extension HKElectrocardiogram.VoltageMeasurement: Harmonizable {
    typealias Harmonized = Electrocardiogram.VoltageMeasurement.Harmonized

    func harmonize() throws -> Harmonized {
        guard
            let quantitiy = quantity(for: .appleWatchSimilarToLeadI)
        else {
            throw HealthKitError.invalidValue(
                "Invalid averageHeartRate value for HKElectrocardiogram"
            )
        }
        let unit = HKUnit.volt()
        let voltage = quantitiy.doubleValue(for: unit)
        return Harmonized(value: voltage, unit: unit.unitString)
    }
}
