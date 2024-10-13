//
//  Extensions+HKCategoryValueAppleWalkingSteadinessEvent.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 04.10.22.
//

import HealthKit

@available(iOS 15.0, *)
extension HKCategoryValueAppleWalkingSteadinessEvent: @retroactive CustomStringConvertible {
    public var description: String {
        "HKCategoryValueAppleWalkingSteadinessEvent"
    }
    public var detail: String {
        switch self {
        case .initialLow:
            return "Initial low"
        case .initialVeryLow:
            return "Initial very low"
        case .repeatLow:
            return "Repeat low"
        case .repeatVeryLow:
            return "Repeat very low"
        @unknown default:
            return "Unknown"
        }
    }
}
