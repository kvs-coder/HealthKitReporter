//
//  Extensions+HKCategoryValueSeverity.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueSeverity {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValueSeverity"
    }
    var detail: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .notPresent:
            return "Not Present"
        case .mild:
            return "Mild"
        case .moderate:
            return "Moderate"
        case .severe:
            return "Severe"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValueSeverity: CategoryValueDescribable {}
