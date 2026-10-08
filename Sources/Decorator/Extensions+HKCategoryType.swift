//
//  Extensions+HKCategoryType.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 27.01.21.
//

import HealthKit

extension HKCategoryType {
    func parsed() throws -> CategoryType {
        if let type = identifier.objectType as? CategoryType {
            return type
        }
        throw HealthKitError.invalidType(
            "Unknown HKCategoryType with identifier:\(identifier)"
        )
    }
}
