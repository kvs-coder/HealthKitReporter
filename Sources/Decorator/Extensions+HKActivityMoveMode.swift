//
//  Extensions+HKActivityMoveMode.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 27.01.21.
//

import HealthKit

extension HKActivityMoveMode: @retroactive CustomStringConvertible {
    public var description: String {
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
