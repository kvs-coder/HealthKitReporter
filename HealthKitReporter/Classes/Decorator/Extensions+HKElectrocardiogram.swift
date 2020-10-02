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
            let averageHeartRate = self.averageHeartRate?.doubleValue(for: averageHeartRateUnit)
        else {
            throw HealthKitError.invalidValue(
                "Invalid averageHeartRate value for HKElectrocardiogram"
            )
        }
        let samplingFrequencyUnit = HKUnit.hertz()
        guard
            let samplingFrequency = self.samplingFrequency?.doubleValue(for: samplingFrequencyUnit)
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
            metadata: self.metadata?.compactMapValues { String(describing: $0 )}
        )
    }
}
