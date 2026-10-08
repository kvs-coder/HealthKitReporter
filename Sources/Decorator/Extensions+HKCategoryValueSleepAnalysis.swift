//
//  Extensions+HKCategoryValueSleepAnalysis.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueSleepAnalysis {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValueSleepAnalysis"
    }
    var detail: String {
        switch self {
        case .inBed:
            return "In Bed"
        case .asleepUnspecified:
            return "Asleep unspecified"
        case .awake:
            return "Awake"
        case .asleepCore:
            return "Asleep core"
        case .asleepDeep:
            return "Asleep deep"
        case .asleepREM:
            return "Asleep REM"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValueSleepAnalysis: CategoryValueDescribable {}
