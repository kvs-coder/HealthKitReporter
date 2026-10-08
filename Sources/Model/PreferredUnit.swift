//
//  PreferredUnit.swift
//  HealthKitReporter
//
//  Created by Victor on 16.11.20.
//

import HealthKit

/// **PreferredUnit** the unit the user prefers for a quantity type
public struct PreferredUnit: Codable {
    public let identifier: String
    public let unit: String

    init(type: HKQuantityType, unit: HKUnit) {
        self.identifier = type.identifier
        self.unit = unit.unitString
    }

    /// Creates the **PreferredUnit** from its fields
    public init(identifier: String, unit: String) {
        self.identifier = identifier
        self.unit = unit
    }
}
// MARK: - Factory
extension PreferredUnit {
    static func collect(
        from dictionary: [HKQuantityType: HKUnit]
    ) -> [PreferredUnit] {
        return dictionary.map { PreferredUnit(type: $0.key, unit: $0.value) }
    }
}
// MARK: - Payload
public extension PreferredUnit {
    static func collect(
        from dictionary: [QuantityType: String]
    ) -> [PreferredUnit] {
        var preferredUnits: [PreferredUnit] = []
        for (key, value) in dictionary {
            if let identifier = key.identifier {
                let preferredUnit = PreferredUnit(
                    identifier: identifier,
                    unit: value
                )
                preferredUnits.append(preferredUnit)
            }
        }
        return preferredUnits
    }
}
// MARK: - Payload
extension PreferredUnit: Payload {
    /**
     Makes a **PreferredUnit** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> PreferredUnit {
        guard
            let identifier = dictionary["identifier"] as? String,
            let unit = dictionary["unit"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return PreferredUnit(identifier: identifier, unit: unit)
    }
}
