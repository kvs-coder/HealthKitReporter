//
//  Extensions+HKVisionPrescriptionType.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 04.10.22.
//

import HealthKit

@available(iOS 16.0, watchOS 9.0, *)
extension HKVisionPrescriptionType {
    /// Name of the value in payload strings
    var label: String {
        "HKVisionPrescriptionType"
    }
    var detail: String {
        switch self {
        case .glasses:
            return "Glasses"
        case .contacts:
            return "Contacts"
        @unknown default:
            return "Unknown"
        }
    }
}
