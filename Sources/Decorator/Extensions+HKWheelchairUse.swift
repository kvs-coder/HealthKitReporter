//
//  Extensions+HKWheelchairUse.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 27.01.21.
//

import HealthKit

@available(iOS 10.0, *)
extension HKWheelchairUse {
    var string: String {
        switch self {
        case .notSet:
            return "na"
        case .no:
            return "No"
        case .yes:
            return "Yes"
        @unknown default:
            fatalError()
        }
    }
}
