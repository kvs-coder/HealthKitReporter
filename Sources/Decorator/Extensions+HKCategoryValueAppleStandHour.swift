//
//  Extensions+HKCategoryValueAppleStandHour.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueAppleStandHour {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValueAppleStandHour"
    }
    var detail: String {
        switch self {
        case .stood:
            return "Stood"
        case .idle:
            return "Idle"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValueAppleStandHour: CategoryValueDescribable {}
