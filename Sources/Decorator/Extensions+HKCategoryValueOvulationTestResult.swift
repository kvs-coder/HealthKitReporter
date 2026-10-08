//
//  Extensions+HKCategoryValueOvulationTestResult.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueOvulationTestResult {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValueOvulationTestResult"
    }
    var detail: String {
        switch self {
        case .negative:
            return "Negative"
        case .luteinizingHormoneSurge:
            return "Luteinizing Hormone Surge"
        case .indeterminate:
            return "Indeterminate"
        case .estrogenSurge:
            return "Estrogen Surge"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValueOvulationTestResult: CategoryValueDescribable {}
