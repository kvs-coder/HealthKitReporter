//
//  Extensions+HKWorkoutSwimmingLocationType.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

extension HKWorkoutSwimmingLocationType {
    /// unknown, pool or open water; Swift accepts any raw value, HealthKit doesn't
    init?(knownRawValue rawValue: Int) {
        guard (0...2).contains(rawValue), let type = HKWorkoutSwimmingLocationType(rawValue: rawValue) else {
            return nil
        }
        self = type
    }
}
