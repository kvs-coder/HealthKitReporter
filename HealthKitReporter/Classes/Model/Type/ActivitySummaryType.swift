//
//  ActivitySummaryType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum ActivitySummaryType: Int, OriginalType {
    public typealias Object = HKActivitySummaryType

    case activitySummaryType

    var original: Object? {
        switch self {
        case .activitySummaryType:
            return HKObjectType.activitySummaryType()
        }
    }
}
