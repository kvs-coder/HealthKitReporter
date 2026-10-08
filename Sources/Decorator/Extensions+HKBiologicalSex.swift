//
//  Extensions+HKBiologicalSex.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

extension HKBiologicalSex {
    /// Name of the value in payload strings
    var label: String {
        switch self {
        case .notSet:
            return "na"
        case .female:
            return "Female"
        case .male:
            return "Male"
        case .other:
            return "Other"
        @unknown default:
            return "Unknown"
        }
    }
}
