//
//  WorkoutType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

/**
 All HealthKit workout types
 */
public enum WorkoutType: Int, CaseIterable, ObjectType {
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
