//
//  Extensions+HKCategoryValueSeverity.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

@available(iOS 13.6, *)
extension HKCategoryValueSeverity: @retroactive CustomStringConvertible {
    public var description: String {
        "HKCategoryValueSeverity"
    }
    public var detail: String {
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
