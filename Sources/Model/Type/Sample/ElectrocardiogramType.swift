//
//  ElectrocardiogramType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import HealthKit

/**
 All HealthKit electrocardiogram types
 */
public enum ElectrocardiogramType: Int, CaseIterable, SampleType {
    case electrocardiogramType

    /// The HealthKit identifier of the type; nil when the type is not available on the running OS
    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        switch self {
        case .electrocardiogramType:
            return HKObjectType.electrocardiogramType()
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension ElectrocardiogramType: HealthKitObjectTypeConvertible {}
