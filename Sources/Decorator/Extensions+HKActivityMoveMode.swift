//
//  Extensions+HKActivityMoveMode.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 27.01.21.
//

import HealthKit

extension HKActivityMoveMode {
    /// Name of the value in payload strings
    var label: String {
        switch self {
        case .activeEnergy:
            return "Active energy"
        case .appleMoveTime:
            return "Apple move time"
        @unknown default:
            return "Unknown"
        }
    }
}
