//
//  ObjectType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import Foundation

public protocol ObjectType {
    /**
     The HealthKit identifier of the type, e.g. "HKQuantityTypeIdentifierStepCount".
     nil when the type is not available on the running OS
     */
    var identifier: String? { get }
}

public extension ObjectType {
    /**
     Makes an **ObjectType** based on it's identifier.
     - Parameter identifier: **String** identifier of the **ObjectType**
     */
    static func make(
        from identifier: String
    ) throws -> Self where Self: CaseIterable {
        let first = Self.allCases.first { identifier == $0.identifier }
        guard let result = first else {
            throw HealthKitError.invalidIdentifier("Invalid identifier: \(identifier)")
        }
        return result
    }
}
