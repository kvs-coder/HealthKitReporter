//
//  Extensions+HKCategoryValueEnvironmentalAudioExposureEvent.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueEnvironmentalAudioExposureEvent: @retroactive CustomStringConvertible {
    public var description: String {
        "HKCategoryValueEnvironmentalAudioExposureEvent"
    }
    public var detail: String {
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
