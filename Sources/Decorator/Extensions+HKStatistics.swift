//
//  Extensions+HKStatistics.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

// SI parsing
extension HKStatistics: Harmonizable {
    typealias Harmonized = Statistics.Harmonized

    func harmonize() throws -> Harmonized {
        return harmonized(unit: try quantityType.siUnit)
    }

    /// Values in **unit**, overall or for one source of a query that separates by source
    func harmonized(unit: HKUnit, for source: HKSource? = nil) -> Harmonized {
        guard let source = source else {
            return Harmonized(
                summary: sumQuantity()?.doubleValue(for: unit),
                average: averageQuantity()?.doubleValue(for: unit),
                recent: mostRecentQuantity()?.doubleValue(for: unit),
                min: minimumQuantity()?.doubleValue(for: unit),
                max: maximumQuantity()?.doubleValue(for: unit),
                unit: unit.unitString,
                duration: duration()?.doubleValue(for: .second())
            )
        }
        return Harmonized(
            summary: sumQuantity(for: source)?.doubleValue(for: unit),
            average: averageQuantity(for: source)?.doubleValue(for: unit),
            recent: mostRecentQuantity(for: source)?.doubleValue(for: unit),
            min: minimumQuantity(for: source)?.doubleValue(for: unit),
            max: maximumQuantity(for: source)?.doubleValue(for: unit),
            unit: unit.unitString,
            duration: duration(for: source)?.doubleValue(for: .second())
        )
    }
}
