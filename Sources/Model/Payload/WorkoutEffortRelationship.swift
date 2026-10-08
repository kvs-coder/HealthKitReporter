//
//  WorkoutEffortRelationship.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// Effort score samples related to a workout or one of its activities (iOS 18+). Read only
public struct WorkoutEffortRelationship: Codable {
    public let workout: Workout
    /// uuid of the workout activity the samples belong to; nil for the whole workout
    public let activityUUID: String?
    /// workout effort score and estimated workout effort score samples
    public let samples: [Quantity]

    public init(workout: Workout, activityUUID: String?, samples: [Quantity]) {
        self.workout = workout
        self.activityUUID = activityUUID
        self.samples = samples
    }

    @available(iOS 18.0, watchOS 11.0, *)
    init(relationship: HKWorkoutEffortRelationship) throws {
        self.workout = try Workout(workout: relationship.workout)
        self.activityUUID = relationship.activity?.uuid.uuidString
        self.samples = (relationship.samples ?? [])
            .compactMap { $0 as? HKQuantitySample }
            .compactMap { try? Quantity(quantitySample: $0) }
    }
}
