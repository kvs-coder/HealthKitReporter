//
//  Extensions+HKWorkoutSessionLocationType.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

extension HKWorkoutSessionLocationType {
    /// unknown, indoor or outdoor; Swift accepts any raw value, HealthKit doesn't
    init?(knownRawValue rawValue: Int) {
        guard (1...3).contains(rawValue), let type = HKWorkoutSessionLocationType(rawValue: rawValue) else {
            return nil
        }
        self = type
    }
}
