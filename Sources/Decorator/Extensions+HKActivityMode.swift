//
//  Extensions+HKActivityMode.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 27.01.21.
//

import Foundation
import HealthKit

@available(iOS 14.0, *)
extension HKActivityMoveMode {
    var string: String {
        switch self {
        case .activeEnergy:
            return "Active energy"
        case .appleMoveTime:
            return "Apple move time"
        @unknown default:
            fatalError()
        }
    }
}
