//
//  Extensions+HKCategoryType.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 27.01.21.
//

import HealthKit

extension HKCategoryType {
    func parsed() throws -> CategoryType {
        for type in CategoryType.allCases {
            if type.identifier == identifier {
                return type
            }
        }
        throw HealthKitError.invalidType(
            "Unknown HKCategoryType with identifier:\(identifier)"
        )
    }
}
