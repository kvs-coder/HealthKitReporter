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

    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        switch self {
        case .activitySummaryType:
            return HKObjectType.activitySummaryType()
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension ActivitySummaryType: HealthKitObjectTypeConvertible {}
