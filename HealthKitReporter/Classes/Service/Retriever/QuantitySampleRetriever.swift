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
    /**
     - Parameters:
        - statistics: statistics (optional)
        - error: error (optional)
    */
    typealias StatisticsCompeltionHandler = (
        _ statistics: Statistics?,
        _ error: Error?
    ) -> Void
    /**
     Queries samples.
     - Parameter type: **QuantityType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     */
    public func sampleQuery(
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
    /**
     Queries statistics.
     - Parameter type: **ObjectType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter completionHandler: returns a block with statistics
     */
    public func statisticsQuery(
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
    /**
     Queries statistics collection.
     - Parameter type: **QuantityType** types
     - Parameter quantitySamplePredicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter anchorDate: **Date** anchor date
     - Parameter enumerateFrom: **Date** start enumeration date
     - Parameter enumerateTo: **Date** end enumeration date
     - Parameter intervalComponents: **DateComponents** components to set the frequency of a collection appearing
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     - Parameter enumerationBlock: returns a block with statistics on every iteration
     */
    public func statisticsCollectionQuery(
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
    /**
     Queries objects (with anchors).
     - Parameter type: **ObjectType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter anchor: **HKQueryAnchor** anchor. HKAnchoredObjectQueryNoAnchor by default
     - Parameter limit: **Int** anchor. HKObjectQueryNoLimit by default
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     - Parameter completionHandler: returns a block with samples
     */
    public func anchoredObjectQuery(
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
