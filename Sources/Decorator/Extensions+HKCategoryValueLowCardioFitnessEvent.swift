//
//  Extensions+HKCategoryValueLowCardioFitnessEvent.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueLowCardioFitnessEvent {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValueLowCardioFitnessEvent"
    }
    var detail: String {
        switch self {
        case .lowFitness:
            return "Low Fitness"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValueLowCardioFitnessEvent: CategoryValueDescribable {}
