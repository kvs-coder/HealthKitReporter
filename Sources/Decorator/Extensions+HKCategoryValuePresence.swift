//
//  Extensions+HKCategoryValuePresence.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValuePresence {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValuePresence"
    }
    var detail: String {
        switch self {
        case .present:
            return "Present"
        case .notPresent:
            return "Not Present"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValuePresence: CategoryValueDescribable {}
