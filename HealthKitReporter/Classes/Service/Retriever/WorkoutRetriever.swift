//
//  WorkoutRetriever.swift
//  HealthKitReporter
//
//  Created by Florian on 21.10.20.
//

import Foundation
import HealthKit

class WorkoutRetriever {
    func makeSampleQuery(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        resultsHandler: @escaping WorkoutResultsHandler
    ) throws -> HKSampleQuery {
        let workoutType = WorkoutType.workoutType
        guard let type = workoutType.original as? HKWorkoutType else {
            throw HealthKitError.invalidType("\(workoutType) can not be represented as HKWorkoutType")
        }
        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (query, data, error) in
            guard
                error == nil,
                let results = data
            else {
                resultsHandler([], error)
                return
            }
            let samples = Workout.collect(
                results: results
            )
            resultsHandler(samples, nil)
        }
        return query
    }

    func makeSourceQuery(
        predicate: NSPredicate?,
        completionHandler: @escaping SourceCompletionHandler
    ) throws -> HKSourceQuery {
        let workoutType = WorkoutType.workoutType
        guard let type = workoutType.original as? HKWorkoutType else {
            throw HealthKitError.invalidType("\(workoutType) can not be represented as HKWorkoutType")
        }
        let query = HKSourceQuery(
            sampleType: type,
            samplePredicate: predicate
        ) { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler([], error)
                return
            }
            let sources = result.map { Source(source: $0) }
            completionHandler(sources, nil)
        }
        return query
    }

    func makeAnchoredObjectQuery(
        predicate: NSPredicate?,
        anchor: HKQueryAnchor? = HKQueryAnchor(
            fromValue: Int(HKAnchoredObjectQueryNoAnchor)
        ),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping WorkoutResultsHandler
    ) throws -> HKAnchoredObjectQuery {
        let workoutType = WorkoutType.workoutType
        guard let type = workoutType.original as? HKWorkoutType else {
            throw HealthKitError.invalidType("\(workoutType) can not be represented as HKWorkoutType")
        }
        let resultsHandler: AnchoredObjectQueryHandler = { (_, data, deletedObjects, anchor, error) in
            guard
                error == nil,
                let results = data
            else {
                completionHandler([], error)
                return
            }
            let samples = Workout.collect(
                results: results
            )
            completionHandler(samples, nil)
        }
        let query = HKAnchoredObjectQuery(
            type: type,
            predicate: predicate,
            anchor: anchor,
            limit: limit,
            resultsHandler: resultsHandler
        )
        if monitorUpdates {
            query.updateHandler = resultsHandler
        }
        return query
    }
}
