//
//  Extensions+HKCategoryValueCervicalMucusQuality.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueCervicalMucusQuality {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValueCervicalMucusQuality"
    }
    var detail: String {
        switch self {
        case .dry:
            return "Dry"
        case .sticky:
            return "Sticky"
        case .creamy:
            return "Creamy"
        case .watery:
            return "Watery"
        case .eggWhite:
            return "Egg White"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValueCervicalMucusQuality: CategoryValueDescribable {}
