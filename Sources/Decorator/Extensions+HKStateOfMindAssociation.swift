//
//  Extensions+HKStateOfMindAssociation.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09.10.26.
//

import HealthKit

@available(iOS 18.0, watchOS 11.0, *)
extension HKStateOfMind.Association {
    /// The 18 associations, raw values 1 through 18; Swift accepts any raw value, HealthKit doesn't
    init(knownRawValue rawValue: Int) throws {
        guard (1...18).contains(rawValue), let value = HKStateOfMind.Association(rawValue: rawValue) else {
            throw HealthKitError.invalidValue("Unknown state of mind association: \(rawValue)")
        }
        self = value
    }
}
