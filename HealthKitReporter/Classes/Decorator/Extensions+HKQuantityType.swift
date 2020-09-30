//
//  Extensions+HKQuantityType.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import Foundation
import HealthKit

extension HKQuantityType {
    var statisticsOptions: HKStatisticsOptions {
        switch self.aggregationStyle {
        case .cumulative:
            return .cumulativeSum
        case .discreteArithmetic,
             .discreteTemporallyWeighted,
             .discreteEquivalentContinuousLevel:
            return .discreteAverage
        @unknown default:
            fatalError()
        }
    }
}
