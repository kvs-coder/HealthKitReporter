//
//  CategorySampleRetriever.swift
//  HealthKitReporter
//
//  Created by Florian on 21.10.20.
//

import Foundation
import HealthKit

class CategorySampleRetriever {
    typealias AnchoredObjectQueryHandler = (
        HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?
    ) -> Void
    typealias CategoryResultsHandler = (
        _ samples: [Category],
        _ error: Error?
    ) -> Void
    typealias SourceCompletionHandler =  (_ sources: [Source], _ error: Error?) -> Void

    func sampleQuery(
        healthStore: HKHealthStore,
        type: CategoryType,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping CategoryResultsHandler
    ) {
        guard let sampleType = type.original else {
            resultsHandler(
                [],
                HealthKitError.invalidType(
                    "\(type) can not be represented as HKSampleType"
                )
            )
            return
        }
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (_, data, error) in
            guard
                error == nil,
                let results = data
            else {
                resultsHandler([], error)
                return
            }
            let samples = Category.collect(results: results)
            resultsHandler(samples, nil)
        }
        healthStore.execute(query)
    }

    func sourceQuery(
        healthStore: HKHealthStore,
        type: QuantityType,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping SourceCompletionHandler
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
        let query = HKSourceQuery(
            sampleType: sampleType,
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
        healthStore.execute(query)
    }

    func anchoredObjectQuery(
        healthStore: HKHealthStore,
        type: CategoryType,
        unit: String,
        predicate: NSPredicate? = .allSamples,
        anchor: HKQueryAnchor? = HKQueryAnchor(
            fromValue: Int(HKAnchoredObjectQueryNoAnchor)
        ),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping CategoryResultsHandler
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
            let samples = Category.collect(results: results)
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
