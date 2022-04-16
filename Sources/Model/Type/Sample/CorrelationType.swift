//
//  CorrelationType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import HealthKit

/**
 All HealthKit correlation types
 */
public enum CorrelationType: Int, CaseIterable, SampleType {
    case bloodPressure
    case food

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .food:
            return HKObjectType.correlationType(forIdentifier: .food)
        case .bloodPressure:
            return HKObjectType.correlationType(forIdentifier: .bloodPressure)
        }
    }
}
