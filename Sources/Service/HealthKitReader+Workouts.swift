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
     - Parameter resultsHandler: returns a block with relationships and the new anchor.
     On an error, no relationships and the **anchor** passed in;
     HealthKitError.parsingFailed when a relationship can't be parsed
     - Throws: HealthKitError.invalidValue for anchor data that doesn't hold a HealthKit anchor
     */
    public func workoutEffortRelationshipQuery(
        predicate: NSPredicate? = nil,
        anchor: Anchor? = nil,
        mostRelevant: Bool = false,
        resultsHandler: @escaping WorkoutEffortRelationshipResultsHandler
    ) throws -> QueryHandle {
        let callerAnchor = anchor
        return QueryHandle(HKWorkoutEffortRelationshipQuery(
            predicate: predicate,
            anchor: try anchor?.asOriginal(),
            options: mostRelevant ? .mostRelevant : .default
        ) { (_, relationships, anchor, error) in
            guard error == nil, let relationships = relationships else {
                resultsHandler([], callerAnchor, error)
                return
            }
            do {
                resultsHandler(
                    try relationships.converted(name: \.parsingName) {
                        try WorkoutEffortRelationship(relationship: $0)
                    },
                    Anchor(anchor),
                    nil
                )
            } catch {
                resultsHandler([], callerAnchor, error)
            }
        })
    }
}
