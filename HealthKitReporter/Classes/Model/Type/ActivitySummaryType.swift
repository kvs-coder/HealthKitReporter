//
//  ActivitySummaryType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum ActivitySummaryType: Int, OriginalType {
    case activitySummaryType

    var original: HKActivitySummaryType? {
        switch self {
        case .activitySummaryType:
            return HKObjectType.activitySummaryType()
        }
    }
}
