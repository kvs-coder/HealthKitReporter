//
//  WorkoutType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum WorkoutType: Int, Original {
    public typealias Object = HKWorkoutType

    case workout

    func asOriginal() throws -> Object {
        switch self {
        case .workout:
            return HKObjectType.workoutType()
        }
    }
}
