//
//  WorkoutType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum WorkoutType: Int, OriginalType {
    public typealias Object = HKWorkoutType

    case workoutType

    var original: Object? {
        switch self {
        case .workoutType:
            return HKObjectType.workoutType()
        }
    }
}
