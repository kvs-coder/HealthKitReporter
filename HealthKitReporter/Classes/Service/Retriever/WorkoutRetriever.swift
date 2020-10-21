//
//  WorkoutRetriever.swift
//  HealthKitReporter
//
//  Created by Florian on 21.10.20.
//

import Foundation
import HealthKit

class WorkoutRetriever {
    typealias AnchoredObjectQueryHandler = (
        HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?
    ) -> Void
    typealias WorkoutResultsHandler = (
        _ samples: [Workout],
        _ error: Error?
    ) -> Void

    func sampleQuery(
        healthStore: HKHealthStore,
        type: QuantityType,
        unit: String,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping WorkoutResultsHandler
    ) {
        guard let quantityType = type.original else {
            resultsHandler(
                [],
                HealthKitError.invalidType(
                    "Invalid HKQuantityType: \(type)"
                )
            )
            return
        }
        let query = HKSampleQuery(
            sampleType: quantityType,
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
        healthStore.execute(query)
    }

    func anchoredObjectQuery(
        healthStore: HKHealthStore,
        type: WorkoutType,
        unit: String,
        predicate: NSPredicate? = .allSamples,
        anchor: HKQueryAnchor? = HKQueryAnchor(
            fromValue: Int(HKAnchoredObjectQueryNoAnchor)
        ),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping WorkoutResultsHandler
    ) {
        guard let sampleType = type.original else {
            completionHandler(
                [],
                HealthKitError.invalidType(
                    "\(type) can not be represented as HKSampleType"
                )
            )
            return
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
            type: sampleType,
            predicate: predicate,
            anchor: anchor,
            limit: limit,
            resultsHandler: resultsHandler
        )
        if monitorUpdates {
            query.updateHandler = resultsHandler
        }
        healthStore.execute(query)
    }
}
