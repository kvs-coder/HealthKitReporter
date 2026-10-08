//
//  Extensions+HKQuantitySample.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

// SI parsing
// MARK: - Harmonizable
extension HKQuantitySample: Harmonizable {
    typealias Harmonized = Quantity.Harmonized

    func harmonize() throws -> Harmonized {
        return quantity(unit: try quantityType.siUnit)
    }

    private func quantity(unit: HKUnit) -> Harmonized {
        let value = quantity.doubleValue(for: unit)
        return Harmonized(
            value: value,
            unit: unit.unitString,
            metadata: metadata?.asMetadata
        )
    }
}
