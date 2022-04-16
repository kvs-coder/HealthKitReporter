//
//  ActivitySummaryType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import HealthKit

/**
 All HealthKit activity summary types
 */
public enum ActivitySummaryType: Int, CaseIterable, ObjectType {
    case activitySummaryType

    public var original: HKObjectType? {
        switch self {
        case .activitySummaryType:
            if #available(iOS 9.3, *) {
                return HKObjectType.activitySummaryType()
            } else {
                return nil
            }
        }
    }
}
