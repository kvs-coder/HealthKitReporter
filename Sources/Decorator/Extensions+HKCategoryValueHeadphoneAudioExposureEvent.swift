//
//  Extensions+HKCategoryValueHeadphoneAudioExposureEvent.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 05.09.21.
//

import HealthKit

extension HKCategoryValueHeadphoneAudioExposureEvent {
    /// Name of the value in payload strings
    var label: String {
        "HKCategoryValueHeadphoneAudioExposureEvent"
    }
    var detail: String {
        switch self {
        case .sevenDayLimit:
            return "Seven Day Limit"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - CategoryValueDescribable
extension HKCategoryValueHeadphoneAudioExposureEvent: CategoryValueDescribable {}
