//
//  ActivitySummaryType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

/**
 All HealthKit activity summary types
 */
public enum ActivitySummaryType: Int, CaseIterable, ObjectType {
    case activitySummaryType

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .activitySummaryType:
            return HKObjectType.activitySummaryType()
        }
    }
}
