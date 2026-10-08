//
//  Extensions+HKCategoryValueContraceptive.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueContraceptive {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValueContraceptive"
    }
    var detail: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .implant:
            return "Implant"
        case .injection:
            return "Injection"
        case .intrauterineDevice:
            return "Intrauterine Device"
        case .intravaginalRing:
            return "Intravaginal Ring"
        case .oral:
            return "Oral"
        case .patch:
            return "Patch"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValueContraceptive: CategoryValueDescribable {}
