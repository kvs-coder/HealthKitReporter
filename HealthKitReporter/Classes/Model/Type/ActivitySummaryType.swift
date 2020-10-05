//
//  ActivitySummaryType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum ActivitySummaryType: Int, ObjectType {
    case activitySummaryType

    public var original: HKActivitySummaryType? {
        switch self {
        case .activitySummaryType:
            return HKObjectType.activitySummaryType()
        }
    }
}
