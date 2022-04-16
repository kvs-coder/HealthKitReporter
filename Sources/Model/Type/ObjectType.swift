//
//  ObjectType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import HealthKit

public protocol ObjectType {
    /**
     Represents type as an original **HKObjectType**
     */
    var original: HKObjectType? { get }
}

public extension ObjectType {
    /**
     Makes an **ObjectType** based on it's identifier.
     - Parameter identifier: **String** identifier of the **ObjectType**
     */
    static func make(
        from identifier: String
    ) throws -> Self where Self: CaseIterable {
        let first = Self.allCases.first { identifier == $0.original?.identifier }
        guard let result = first else {
            throw HealthKitError.invalidIdentifier("Invalid identifier: \(identifier)")
        }
        return result
    }
}
