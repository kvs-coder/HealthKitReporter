//
//  Extensions+HKElectrocardiogram.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import HealthKit

extension HKElectrocardiogram {
    typealias Harmonized = Electrocardiogram.Harmonized

    func harmonize(voltageMeasurements: [Electrocardiogram.VoltageMeasurement]) throws -> Harmonized {
        let averageHeartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let averageHeartRate = averageHeartRate?.doubleValue(for: averageHeartRateUnit)
        let samplingFrequencyUnit = HKUnit.hertz()
        guard
            let samplingFrequency = samplingFrequency?.doubleValue(for: samplingFrequencyUnit)
        else {
            throw HealthKitError.invalidValue(
                "Invalid samplingFrequency value for HKElectrocardiogram"
            )
        }
        return Harmonized(
            averageHeartRate: averageHeartRate,
            averageHeartRateUnit: averageHeartRateUnit.unitString,
            samplingFrequency: samplingFrequency,
            samplingFrequencyUnit: samplingFrequencyUnit.unitString,
            classification: classification.label,
            symptomsStatus: symptomsStatus.label,
            count: numberOfVoltageMeasurements,
            voltageMeasurements: voltageMeasurements,
            metadata: metadata?.asMetadata
        )
    }
}
