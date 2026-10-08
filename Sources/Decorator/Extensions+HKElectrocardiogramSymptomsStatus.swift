//
//  Extensions+HKElectrocardiogramSymptomsStatus.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import HealthKit

// MARK: - Label
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
