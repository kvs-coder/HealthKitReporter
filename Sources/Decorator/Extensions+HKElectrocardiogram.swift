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

extension HKElectrocardiogram.VoltageMeasurement: Harmonizable {
    typealias Harmonized = Electrocardiogram.VoltageMeasurement.Harmonized

    func harmonize() throws -> Harmonized {
        guard
            let quantitiy = quantity(for: .appleWatchSimilarToLeadI)
        else {
            throw HealthKitError.invalidValue(
                "No Apple Watch lead I voltage in HKElectrocardiogram.VoltageMeasurement"
            )
        }
        let unit = HKUnit.volt()
        let voltage = quantitiy.doubleValue(for: unit)
        return Harmonized(value: voltage, unit: unit.unitString)
    }
}
// MARK: - CustomStringConvertible
extension HKElectrocardiogram.Classification {
    /// Name of the value in payload strings
    var label: String {
        switch self {
        case .notSet:
            return "na"
        case .sinusRhythm:
            return "Sinus rhythm"
        case .atrialFibrillation:
            return "Atrial fibrillation"
        case .inconclusiveLowHeartRate:
            return "Inconclusive low heart rate"
        case .inconclusiveHighHeartRate:
            return "Inconclusive high heart rate"
        case .inconclusivePoorReading:
            return "Inconclusive poor reading"
        case .inconclusiveOther:
            return "Inconclusive other"
        case .unrecognized:
            return "Unrecognized"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CustomStringConvertible
extension HKElectrocardiogram.SymptomsStatus {
    /// Name of the value in payload strings
    var label: String {
        switch self {
        case .notSet:
            return "na"
        case .none:
            return "None"
        case .present:
            return "Present"
        @unknown default:
            return "Unknown"
        }
    }
}
