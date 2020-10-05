//
//  WorkoutType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum WorkoutType: Int, ObjectType {
    case workoutType

    public var original: HKWorkoutType? {
        switch self {
        case .workoutType:
            return HKObjectType.workoutType()
        }
    }
}
