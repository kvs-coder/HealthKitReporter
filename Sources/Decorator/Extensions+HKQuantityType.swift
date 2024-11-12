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

    var statisticsOptions: HKStatisticsOptions {
        switch aggregationStyle {
        case .cumulative:
            return .cumulativeSum
        case .discreteArithmetic,
             .discreteTemporallyWeighted,
             .discreteEquivalentContinuousLevel:
            return [.discreteAverage, .discreteMax]
        @unknown default:
            fatalError()
        }
    }
}
