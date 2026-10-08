//
//  Extensions+HKCategoryValuePregnancyTestResult.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 04.10.22.
//

import HealthKit

extension HKCategoryValuePregnancyTestResult {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValuePregnancyTestResult"
    }
    var detail: String {
        switch self {
        case .negative:
            return "Negative"
        case .positive:
            return "Positive"
        case .indeterminate:
            return "Indeterminate"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValuePregnancyTestResult: CategoryValueDescribable {}
