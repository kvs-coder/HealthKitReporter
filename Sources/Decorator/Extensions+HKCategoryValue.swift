//
//  Extensions+HKCategoryValue.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValue: @retroactive CustomStringConvertible {
    public var description: String {
        "HKCategoryValue"
    }
    public var detail: String {
        switch self {
        case .notApplicable:
            return "Not Applicable"
        @unknown default:
            return "Unknown"
        }
    }
}
