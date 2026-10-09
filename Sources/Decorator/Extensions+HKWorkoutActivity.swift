//
//  Extensions+HKWorkoutActivity.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09.10.26.
//

import HealthKit

@available(iOS 16.0, watchOS 9.0, *)
extension HKWorkoutActivity {
    /// Names the activity in errors: its activity type and uuid
    var parsingName: String {
        return "\(workoutConfiguration.activityType.label) workout activity \(uuid.uuidString)"
    }
}
