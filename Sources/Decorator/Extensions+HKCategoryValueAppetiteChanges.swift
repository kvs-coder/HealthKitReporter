//
//  Extensions+HKCategoryValueAppetiteChanges.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

@available(iOS 13.6, *)
extension HKCategoryValueAppetiteChanges: @retroactive CustomStringConvertible {
    public var description: String {
        "HKCategoryValueAppetiteChanges"
    }
    public var detail: String {
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
