//
//  WorkoutType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import HealthKit

/**
 All HealthKit workout types
 */
public enum WorkoutType: Int, CaseIterable, SampleType {
    case workoutType

    /// The HealthKit identifier of the type; nil when the type is not available on the running OS
    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        switch self {
        case .workoutType:
            return HKObjectType.workoutType()
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension WorkoutType: HealthKitObjectTypeConvertible {}
