//
//  Extensions+HKCategoryValueEnvironmentalAudioExposureEvent.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

@available(iOS 14.0, *)
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
