//
//  ActivitySummaryType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum ActivitySummaryType: Int, Original {
    public typealias Object = HKActivitySummaryType

    case activitySummary

    func asOriginal() throws -> Object {
        switch self {
        case .activitySummary:
            return HKObjectType.activitySummaryType()
        }
    }
}
