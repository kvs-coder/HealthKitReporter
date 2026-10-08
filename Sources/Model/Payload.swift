//
//  Payload.swift
//  HealthKitReporter
//
//  Created by Victor on 15.11.20.
//

import Foundation

/// **Payload** a value the library builds from a dictionary, e.g. one the Flutter plugin sends
public protocol Payload {
    /**
     Makes the payload from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    static func make(from dictionary: [String: Any]) throws -> Self
}

public extension Payload {
    /**
     Makes a payload of every dictionary in the array; elements that aren't dictionaries are skipped.
     - Parameter array: **[Any]** array of dictionaries
     - Throws: HealthKitError.invalidValue when a dictionary is invalid
     */
    static func collect(from array: [Any]) throws -> [Self] {
        return try array.compactMap { $0 as? [String: Any] }.map(make)
    }
}
