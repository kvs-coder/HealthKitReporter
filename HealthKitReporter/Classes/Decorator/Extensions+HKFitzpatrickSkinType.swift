//
//  Extensions+HKFitzpatrickSkinType.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import Foundation
import HealthKit

extension HKFitzpatrickSkinType {
    var string: String {
        switch self {
        case .notSet:
            return "na"
        case .I:
            return "I"
        case .II:
            return "II"
        case .III:
            return "III"
        case .IV:
            return "IV"
        case .V:
            return "V"
        case .VI:
            return "VI"
        @unknown default:
            fatalError()
        }
    }
}
