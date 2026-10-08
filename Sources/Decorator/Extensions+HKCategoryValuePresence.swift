//
//  Extensions+HKCategoryValuePresence.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

@available(iOS 13.6, *)
extension HKCategoryValuePresence: @retroactive CustomStringConvertible {
    public var description: String {
        "HKCategoryValuePresence"
    }
    public var detail: String {
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
