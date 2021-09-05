//
//  Extensions+HKCategoryValueSleepAnalysis.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import Foundation
import HealthKit

extension HKCategoryValueSleepAnalysis: CustomStringConvertible {
    public var description: String {
        "HKCategoryValueSleepAnalysis"
    }
    public var detail: String {
        switch self {
        case .inBed:
            return "In Bed"
        case .asleep:
            return "Asleep"
        case .awake:
            return "Awake"
        @unknown default:
            return "Unknown"
        }
    }
}
