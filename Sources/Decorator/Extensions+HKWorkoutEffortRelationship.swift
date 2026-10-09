//
//  Extensions+HKWorkoutEffortRelationship.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09.10.26.
//

import HealthKit

@available(iOS 18.0, watchOS 11.0, *)
extension HKWorkoutEffortRelationship {
    /// Names the relationship in errors: its workout uuid
    var parsingName: String {
        return "workout effort relationship of workout \(workout.uuid.uuidString)"
    }
}
