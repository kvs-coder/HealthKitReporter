//
//  Extensions+HKCategoryValueVaginalBleeding.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

@available(iOS 18.0, *)
extension HKCategoryValueVaginalBleeding: @retroactive CustomStringConvertible {
    public var description: String {
        "HKCategoryValueVaginalBleeding"
    }
    public var detail: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .light:
            return "Light"
        case .medium:
            return "Medium"
        case .heavy:
            return "Heavy"
        case .none:
            return "None"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
@available(iOS 18.0, *)
extension HKCategoryValueVaginalBleeding: CategoryValueDescribable {}
