//
//  Extensions+HKCategoryValueAppetiteChanges.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueAppetiteChanges {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValueAppetiteChanges"
    }
    var detail: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .noChange:
            return "No Change"
        case .decreased:
            return "Decreased"
        case .increased:
            return "Increased"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValueAppetiteChanges: CategoryValueDescribable {}
