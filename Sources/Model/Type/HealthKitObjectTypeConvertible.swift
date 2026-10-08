//
//  HealthKitObjectTypeConvertible.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// A library type backed by an **HKObjectType**; internal, so HealthKit types stay out of the public API
protocol HealthKitObjectTypeConvertible: ObjectType {
    var original: HKObjectType? { get }
}

extension ObjectType {
    /// The HealthKit type of a library type, nil for unavailable or foreign conformances
    var hkObjectType: HKObjectType? {
        return (self as? HealthKitObjectTypeConvertible)?.original
    }
}
