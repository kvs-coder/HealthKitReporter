//
//  CategorySampleRetriever.swift
//  HealthKitReporter
//
//  Created by Victor on 21.10.20.
//

import Foundation
import HealthKit

class CategorySampleRetriever {
    func makeSampleQuery(
        type: CategoryType,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        resultsHandler: @escaping CategoryResultsHandler
    ) throws -> HKSampleQuery {
        guard let sampleType = type.original as? HKCategoryType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKCategoryType")
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
        return query
    }

    func makeSourceQuery(
        type: QuantityType,
        predicate: NSPredicate?,
        completionHandler: @escaping SourceCompletionHandler
    ) throws -> HKSourceQuery {
        guard let sampleType = type.original as? HKCategoryType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKCategoryType")
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
        return query
    }

    func makeAnchoredObjectQuery(
        type: CategoryType,
        predicate: NSPredicate?,
        anchor: HKQueryAnchor?,
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping CategoryResultsHandler
    ) throws -> HKAnchoredObjectQuery {
        guard let sampleType = type.original as? HKCategoryType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKCategoryType")
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
        return query
    }
}
