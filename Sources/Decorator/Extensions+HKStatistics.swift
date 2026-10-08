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
        let unit = try quantityType.siUnit
        return Harmonized(
            summary: sumQuantity()?.doubleValue(for: unit),
            average: averageQuantity()?.doubleValue(for: unit),
            recent: mostRecentQuantity()?.doubleValue(for: unit),
            min: minimumQuantity()?.doubleValue(for: unit),
            max: maximumQuantity()?.doubleValue(for: unit),
            unit: unit.unitString
        )
    }
}
