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

    /// Creates the **WorkoutEffortRelationship** from its fields
    public init(workout: Workout, activityUUID: String?, samples: [Quantity]) {
        self.workout = workout
        self.activityUUID = activityUUID
        self.samples = samples
    }

    @available(iOS 18.0, watchOS 11.0, *)
    init(relationship: HKWorkoutEffortRelationship) throws {
        self.workout = try Workout(workout: relationship.workout)
        self.activityUUID = relationship.activity?.uuid.uuidString
        self.samples = try (relationship.samples ?? []).converted { (sample: HKQuantitySample) in
            try Quantity(quantitySample: sample)
        }
    }
}
// MARK: - Payload
extension WorkoutEffortRelationship: Payload {
    /**
     Makes a **WorkoutEffortRelationship** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> WorkoutEffortRelationship {
        guard
            let workout = dictionary["workout"] as? [String: Any],
            let samples = dictionary["samples"] as? [Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return WorkoutEffortRelationship(
            workout: try Workout.make(from: workout),
            activityUUID: dictionary["activityUUID"] as? String,
            samples: try Quantity.collect(from: samples)
        )
    }
}
