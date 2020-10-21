//
//  QuantitySampleRetriever.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

class QuantitySampleRetriever {
    typealias AnchoredObjectQueryHandler = (
        HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?
    ) -> Void
    typealias StatisticsCollectionHandler = (
        HKStatisticsCollection?, Error?
    ) -> Void
    typealias QuantityResultsHandler = (
        _ samples: [Quantity],
        _ error: Error?
    ) -> Void
    typealias SourceCompletionHandler =  (_ sources: [Source], _ error: Error?) -> Void
    typealias StatisticsCompeltionHandler = (
        _ statistics: Statistics?,
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
        resultsHandler: @escaping QuantityResultsHandler
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
            let samples = Quantity.collect(
                results: results,
                unit: HKUnit.init(from: unit)
            )
            resultsHandler(samples, nil)
        }
        healthStore.execute(query)
    }

    func statisticsQuery(
        healthStore: HKHealthStore,
        type: QuantityType,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping StatisticsCompeltionHandler
    ) {
        guard let quantityType = type.original else {
            completionHandler(
                nil,
                HealthKitError.invalidType(
                    "\(type) can not be represented as HKQuantityType"
                )
            )
            return
        }
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: quantityType.statisticsOptions
        ) { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler(nil, error)
                return
            }
            do {
                let statistics = try Statistics(statistics: result)
                completionHandler(statistics, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        healthStore.execute(query)
    }

    func statisticsCollectionQuery(
        healthStore: HKHealthStore,
        type: QuantityType,
        quantitySamplePredicate: NSPredicate? = .allSamples,
        anchorDate: Date,
        enumerateFrom: Date,
        enumerateTo: Date,
        intervalComponents: DateComponents,
        monitorUpdates: Bool = false,
        enumerationBlock: @escaping StatisticsCompeltionHandler
    ) {
        guard let quantityType = type.original else {
            enumerationBlock(
                nil,
                HealthKitError.invalidType(
                    "\(type) can not be represented as HKQuantityType"
                )
            )
            return
        }
        let resultsHandler: StatisticsCollectionHandler = { (data, error) in
            guard
                error == nil,
                let result = data
            else {
                enumerationBlock(nil, error)
                return
            }
            result.enumerateStatistics(
                from: enumerateFrom,
                to: enumerateTo
            ) { (data, stop) in
                do {
                    let statistics = try Statistics(statistics: data)
                    enumerationBlock(statistics, nil)
                } catch {
                    enumerationBlock(nil, error)
                }
            }
        }
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: quantitySamplePredicate,
            options: quantityType.statisticsOptions,
            anchorDate: anchorDate,
            intervalComponents: intervalComponents
        )
        query.initialResultsHandler = { (_, result, error) in
            resultsHandler(result, error)
        }
        if monitorUpdates {
            query.statisticsUpdateHandler = { (_, _, result, error) in
                resultsHandler(result, error)
            }
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
        type: QuantityType,
        unit: String,
        predicate: NSPredicate? = .allSamples,
        anchor: HKQueryAnchor? = HKQueryAnchor(
            fromValue: Int(HKAnchoredObjectQueryNoAnchor)
        ),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping QuantityResultsHandler
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
            let samples = Quantity.collect(
                results: results,
                unit: HKUnit.init(from: unit)
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
