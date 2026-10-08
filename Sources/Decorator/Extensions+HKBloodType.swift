//
//  Extensions+HKBloodType.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

extension HKBloodType {
    /// Name of the value in payload strings
    var label: String {
        switch self {
        case .notSet:
            return "na"
        case .aPositive:
            return "A+"
        case .aNegative:
            return "A-"
        case .bPositive:
            return "B+"
        case .bNegative:
            return "B-"
        case .abPositive:
            return "AB+"
        case .abNegative:
            return "AB-"
        case .oPositive:
            return "O+"
        case .oNegative:
            return "O-"
        @unknown default:
            return "Unknown"
        }
    }
}
