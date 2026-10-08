//
//  Extensions+HKCategoryValuePresence.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

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
// MARK: - CategoryValueDescribable
extension HKCategoryValuePresence: CategoryValueDescribable {}
