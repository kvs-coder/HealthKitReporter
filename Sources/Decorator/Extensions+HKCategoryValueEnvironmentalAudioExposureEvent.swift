//
//  Extensions+HKCategoryValueEnvironmentalAudioExposureEvent.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueEnvironmentalAudioExposureEvent {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValueEnvironmentalAudioExposureEvent"
    }
    var detail: String {
        switch self {
        case .momentaryLimit:
            return "Momentary Limit"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValueEnvironmentalAudioExposureEvent: CategoryValueDescribable {}
