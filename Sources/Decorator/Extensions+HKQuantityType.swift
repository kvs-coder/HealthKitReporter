//
//  Extensions+HKQuantityType.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

extension HKQuantityType {
    func parsed() throws -> QuantityType {
        for type in QuantityType.allCases {
            if type.identifier == identifier {
                return type
            }
        }
        throw HealthKitError.invalidType("Unknown HKObjectType")
    }
    /// Parses the unit string and checks that it fits the type, so HealthKit never raises on it
    func compatibleUnit(from unitString: String) throws -> HKUnit {
        let unit = try HKUnit.parsed(from: unitString)
        guard `is`(compatibleWith: unit) else {
            throw HealthKitError.invalidValue(
                "Unit \(unitString) is not compatible with \(identifier)"
            )
        }
        return unit
    }

    var statisticsOptions: HKStatisticsOptions {
        switch aggregationStyle {
        case .cumulative:
            return .cumulativeSum
        case .discreteArithmetic,
             .discreteTemporallyWeighted,
             .discreteEquivalentContinuousLevel:
            return [.discreteAverage, .discreteMin, .discreteMax, .mostRecent]
        @unknown default:
            return []
        }
    }
}
