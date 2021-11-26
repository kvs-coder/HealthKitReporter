//
//  PreferredUnit.swift
//  HealthKitReporter
//
//  Created by Victor on 16.11.20.
//

import Foundation
import HealthKit

@objc(HKRPreferredUnit)
public final class PreferredUnit: NSObject, Codable {
    @objc
    public let identifier: String
    @objc
    public let unit: String

    init(type: HKQuantityType, unit: HKUnit) {
        self.identifier = type.identifier
        self.unit = unit.unitString
    }

    @objc
    public init(identifier: String, unit: String) {
        self.identifier = identifier
        self.unit = unit
    }
}
// MARK: - Factory
public extension PreferredUnit {
    @objc
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
    @objc
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
    @objc
    public static func make(
        from dictionary: [String : Any]
    ) throws -> PreferredUnit {
        guard
            let identifier = dictionary["identifier"] as? String,
            let unit = dictionary["unit"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return PreferredUnit(identifier: identifier, unit: unit)
    }
}
