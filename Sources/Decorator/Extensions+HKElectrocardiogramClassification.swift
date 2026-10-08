//
//  Extensions+HKElectrocardiogramClassification.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import HealthKit

// MARK: - Label
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
