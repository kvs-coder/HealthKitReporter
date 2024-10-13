//
//  Extensions+HKCategoryValueAudioExposureEvent.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

@available(iOS 13.0, *)
extension HKCategoryValueAudioExposureEvent: @retroactive CustomStringConvertible {
    public var description: String {
        "HKCategoryValueAudioExposureEvent"
    }
    public var detail: String {
        switch self {
        case .loudEnvironment:
            return "Load Environment"
        @unknown default:
            return "Unknown"
        }
    }
}
