//
//  StateOfMindType.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/**
 All HealthKit state of mind types
 */
public enum StateOfMindType: Int, CaseIterable, SampleType {
    case stateOfMind

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .stateOfMind:
            if #available(iOS 18.0, watchOS 11.0, *) {
                return HKObjectType.stateOfMindType()
            }
            return nil
        }
    }
}
