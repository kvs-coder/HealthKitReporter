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

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .workoutType:
            return HKObjectType.workoutType()
        }
    }
}
