//
//  Extensions+HKCategoryValueContraceptive.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

@available(iOS 14.3, *)
extension HKCategoryValueContraceptive: @retroactive CustomStringConvertible {
    public var description: String {
        "HKCategoryValueContraceptive"
    }
    public var detail: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .implant:
            return "Implant"
        case .injection:
            return "Injection"
        case .intrauterineDevice:
            return "Intrauterine Device"
        case .intravaginalRing:
            return "Intravaginal Ring"
        case .oral:
            return "Oral"
        case .patch:
            return "Patch"
        @unknown default:
            return "Unknown"
        }
    }
}
