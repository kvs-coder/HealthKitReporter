//
//  Extensions+HKWheelchairUse.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 27.01.21.
//

import Foundation
import HealthKit

extension HKWheelchairUse {
    var string: String {
        switch self {
        case .notSet:
            return "Not set"
        case .no:
            return "No"
        case .yes:
            return "Yes"
        @unknown default:
            fatalError()
        }
    }
}
