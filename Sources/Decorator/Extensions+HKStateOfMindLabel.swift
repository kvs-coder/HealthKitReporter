//
//  Extensions+HKStateOfMindLabel.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09.10.26.
//

import HealthKit

@available(iOS 18.0, watchOS 11.0, *)
extension HKStateOfMind.Label {
    /// The 38 labels, raw values 1 through 38; Swift accepts any raw value, HealthKit doesn't
    init(knownRawValue rawValue: Int) throws {
        guard (1...38).contains(rawValue), let value = HKStateOfMind.Label(rawValue: rawValue) else {
            throw HealthKitError.invalidValue("Unknown state of mind label: \(rawValue)")
        }
        self = value
    }
}
