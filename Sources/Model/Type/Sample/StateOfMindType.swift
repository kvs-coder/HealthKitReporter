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

    /// The HealthKit identifier of the type; nil when the type is not available on the running OS
    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        switch self {
        case .stateOfMind:
            if #available(iOS 18.0, watchOS 11.0, *) {
                return HKObjectType.stateOfMindType()
            }
            return nil
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension StateOfMindType: HealthKitObjectTypeConvertible {}
