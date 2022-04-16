//
//  PreferredUnit.swift
//  HealthKitReporter
//
//  Created by Victor on 16.11.20.
//

import HealthKit

public struct PreferredUnit: Codable {
    public let identifier: String
    public let unit: String

    init(type: HKQuantityType, unit: HKUnit) {
        self.identifier = type.identifier
        self.unit = unit.unitString
    }

    public init(identifier: String, unit: String) {
        self.identifier = identifier
        self.unit = unit
    }
}
// MARK: - Payload
public extension PreferredUnit {
    static func collect(
        from dictionary: [HKQuantityType : HKUnit]
    ) -> [PreferredUnit] {
        var preferredUnits: [PreferredUnit] = []
        for (key, value) in dictionary {
            let preferredUnit = PreferredUnit(
                type: key,
                unit: value
            )
            preferredUnits.append(preferredUnit)
        }
        return preferredUnits
    }
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
