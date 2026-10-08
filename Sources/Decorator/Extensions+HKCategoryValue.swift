//
//  Extensions+HKCategoryValue.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValue {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValue"
    }
    var detail: String {
        switch self {
        case .notApplicable:
            return "Not Applicable"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValue: CategoryValueDescribable {}
