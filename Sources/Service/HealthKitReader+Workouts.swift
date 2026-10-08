//
//  HealthKitReader+Workouts.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

// MARK: - Workouts
@available(iOS 18.0, watchOS 11.0, *)
extension HealthKitReader {
    /**
     Queries the effort score samples related to workouts.
     - Parameter predicate: **NSPredicate** workout predicate (optional). nil by default
     - Parameter anchor: **Anchor** anchor (optional). nil by default
     - Parameter mostRelevant: **Bool** only the most relevant effort sample per workout. False by default
     - Parameter resultsHandler: returns a block with relationships and the new anchor
     */
    public func workoutEffortRelationshipQuery(
        predicate: NSPredicate? = nil,
        anchor: Anchor? = nil,
        mostRelevant: Bool = false,
        resultsHandler: @escaping WorkoutEffortRelationshipResultsHandler
    ) -> WorkoutEffortRelationshipQuery {
        return HKWorkoutEffortRelationshipQuery(
            predicate: predicate,
            anchor: anchor,
            options: mostRelevant ? .mostRelevant : .default
        ) { (_, relationships, anchor, error) in
            guard error == nil, let relationships = relationships else {
                resultsHandler([], anchor, error)
                return
            }
            resultsHandler(
                relationships.compactMap { try? WorkoutEffortRelationship(relationship: $0) },
                anchor,
                nil
            )
        }
    }
}
