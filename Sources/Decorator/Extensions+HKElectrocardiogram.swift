//
//  Extensions+HKElectrocardiogram.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import HealthKit

@available(iOS 14.0, *)
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
            classification: classification.description,
            classificationKey: classification.key,
            symptomsStatus: symptomsStatus.description,
            symptomsStatusKey: symptomsStatus.key,
            count: numberOfVoltageMeasurements,
            voltageMeasurements: voltageMeasurements,
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
// MARK: - CustomStringConvertible
@available(iOS 14.0, *)
extension HKElectrocardiogram.Classification: CustomStringConvertible {
    public var key: String {
        switch self {
        case .notSet:
            return "notSet"
        case .sinusRhythm:
            return "sinusRhythm"
        case .atrialFibrillation:
            return "atrialFibrillation"
        case .inconclusiveLowHeartRate:
            return "inconclusiveLowHeartRate"
        case .inconclusiveHighHeartRate:
            return "inconclusiveHighHeartRate"
        case .inconclusivePoorReading:
            return "inconclusivePoorReading"
        case .inconclusiveOther:
            return "inconclusiveOther"
        case .unrecognized:
            return "unrecognized"
        @unknown default:
            fatalError()
        }
    }
    
    public var description: String {
        switch self {
        case .notSet:
            return "na"
        case .sinusRhythm:
            return "Sinus rhytm"
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
            fatalError()
        }
    }
}
// MARK: - CustomStringConvertible
@available(iOS 14.0, *)
extension HKElectrocardiogram.SymptomsStatus: CustomStringConvertible {
    public var key: String {
        switch self {
        case .notSet:
            return "notSet"
        case .none:
            return "none"
        case .present:
            return "present"
        @unknown default:
            fatalError()
        }
    }
    public var description: String {
        switch self {
        case .notSet:
            return "na"
        case .none:
            return "None"
        case .present:
            return "Present"
        @unknown default:
            fatalError()
        }
    }
}
