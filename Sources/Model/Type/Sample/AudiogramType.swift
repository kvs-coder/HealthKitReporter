//
//  AudiogramType.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/**
 All HealthKit audiogram types
 */
public enum AudiogramType: Int, CaseIterable, SampleType {
    case audiogram

    /// The HealthKit identifier of the type; nil when the type is not available on the running OS
    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        switch self {
        case .audiogram:
            return HKObjectType.audiogramSampleType()
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension AudiogramType: HealthKitObjectTypeConvertible {}
