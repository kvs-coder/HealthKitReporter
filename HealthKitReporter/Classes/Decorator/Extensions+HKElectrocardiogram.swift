//
//  Extensions+HKElectrocardiogram.swift
//  HealthKitReporter
//
//  Created by Florian on 24.09.20.
//

import Foundation
import HealthKit

@available(iOS 14.0, *)
extension HKElectrocardiogram: HealthKitParsable {
    typealias Parseble = Electrocardiogram

    func parsed() throws -> Electrocardiogram {
        return Electrocardiogram(electrocardiogram: self)
    }

    func averageHeartRate() throws -> (value: Double, unit: String) {
        let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        guard let value = self.averageHeartRate?.doubleValue(for: unit) else {
            throw HealthKitError.invalidValue(
                "Invalid averageHeartRate value for HKElectrocardiogram"
            )
        }
        return (value, unit.unitString)
    }
    func samplingFrequency() throws -> (value: Double, unit: String) {
        let unit = HKUnit.hertz()
        guard let value = self.samplingFrequency?.doubleValue(for: unit) else {
            throw HealthKitError.invalidValue(
                "Invalid samplingFrequency value for HKElectrocardiogram"
            )
        }
        return (value, unit.unitString)
    }
    func classification() -> String {
        switch self.classification {
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
    func symptomsStatus() -> String {
        switch self.symptomsStatus {
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
}
