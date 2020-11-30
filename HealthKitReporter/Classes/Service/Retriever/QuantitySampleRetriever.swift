//
//  QuantitySampleRetriever.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import Foundation
import HealthKit

class QuantitySampleRetriever {
    func makeSampleQuery(
        type: QuantityType,
        unit: String,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        resultsHandler: @escaping QuantityResultsHandler
    ) throws -> HKSampleQuery {
        guard let quantityType = type.original as? HKQuantityType else {
            throw HealthKitError.invalidType("Invalid HKQuantityType: \(type)")
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
        return query
    }

    func makeStatisticsQuery(
        type: QuantityType,
        unit: String,
        predicate: NSPredicate?,
        completionHandler: @escaping StatisticsCompeltionHandler
    ) throws -> HKStatisticsQuery {
        guard let quantityType = type.original as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKQuantityType"
            )
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
                let statistics = try Statistics(
                    statistics: result,
                    unit: HKUnit.init(from: unit)
                )
                completionHandler(statistics, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        return query
    }

    func makeStatisticsCollectionQuery(
        type: QuantityType,
        unit: String,
        quantitySamplePredicate: NSPredicate?,
        anchorDate: Date,
        enumerateFrom: Date,
        enumerateTo: Date,
        intervalComponents: DateComponents,
        monitorUpdates: Bool,
        enumerationBlock: @escaping StatisticsCompeltionHandler
    ) throws -> HKStatisticsCollectionQuery {
        guard let quantityType = type.original as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKQuantityType"
            )
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
                    let statistics = try Statistics(
                        statistics: data,
                        unit: HKUnit.init(from: unit)
                    )
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
        return query
    }

    func makeSourceQuery(
        type: QuantityType,
        predicate: NSPredicate?,
        completionHandler: @escaping SourceCompletionHandler
    ) throws -> HKSourceQuery {
        guard let sampleType = type.original as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKQuantityType"
            )
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
        type: QuantityType,
        unit: String,
        predicate: NSPredicate?,
        anchor: HKQueryAnchor? = HKQueryAnchor(
            fromValue: Int(HKAnchoredObjectQueryNoAnchor)
        ),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping QuantityResultsHandler
    ) throws -> HKAnchoredObjectQuery {
        guard let sampleType = type.original as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKQuantityType"
            )
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
        return query
    }
}
