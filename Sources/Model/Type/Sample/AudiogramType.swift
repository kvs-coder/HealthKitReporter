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

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .audiogram:
            return HKObjectType.audiogramSampleType()
        }
    }
}
