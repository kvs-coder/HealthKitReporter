//
//  Extensions+HKCategoryValueLowCardioFitnessEvent.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

@available(iOS 14.3, *)
extension HKCategoryValueLowCardioFitnessEvent: @retroactive CustomStringConvertible {
    public var description: String {
        "HKCategoryValueLowCardioFitnessEvent"
    }
    public var detail: String {
        switch self {
        case .lowFitness:
            return "Low Fitness"
        @unknown default:
            return "Unknown"
        }
    }
}
