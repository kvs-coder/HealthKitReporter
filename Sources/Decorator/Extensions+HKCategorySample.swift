//
//  Extensions+HKCategorySample.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

// MARK: - Harmonizable
extension HKCategorySample: Harmonizable {
    typealias Harmonized = Category.Harmonized

    func harmonize() throws -> Harmonized {
        let categoryValue = try categoryType.parsed().describedValue(value)
        return Harmonized(
            value: value,
            description: categoryValue?.label ?? String(),
            detail: categoryValue?.detail ?? String(),
            metadata: metadata?.asMetadata
        )
    }
}
