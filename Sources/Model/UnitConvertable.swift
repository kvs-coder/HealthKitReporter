//
//  UnitConvertable.swift
//  HealthKitReporter
//
//  Created by Vignesh J on 16/02/21.
//

import Foundation

/// **UnitConvertable** a payload whose values can be expressed in another unit
public protocol UnitConvertable {
    /**
     A copy with the values in another unit.
     - Parameter unit: **String** unit compatible with the type, e.g. "km"
     - Throws: HealthKitError.invalidType, HealthKitError.invalidValue on a malformed or incompatible unit
     */
    func converted(to unit: String) throws -> Self
}
