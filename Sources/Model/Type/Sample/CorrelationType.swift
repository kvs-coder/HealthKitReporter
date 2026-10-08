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

    /// The HealthKit identifier of the type; nil when the type is not available on the running OS
    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        switch self {
        case .food:
            return HKObjectType.correlationType(forIdentifier: .food)
        case .bloodPressure:
            return HKObjectType.correlationType(forIdentifier: .bloodPressure)
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension CorrelationType: HealthKitObjectTypeConvertible {}
