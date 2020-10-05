//
//  HealthKitReader.swift
//  HealthKitReader
//
//  Created by Victor on 23.09.20.
//

import Foundation
import HealthKit

public class HealthKitReader {
    /**
     - Parameters:
        - success: the status
        - error: error (optional)
    */
    public typealias StatusCompletionBlock = (_ success: Bool, _ error: Error?) -> Void
    /**
     - Parameters:
        - statistics: statistics (optional)
        - error: error (optional)
    */
    public typealias StatisticsCompeltionHandler = (_ statistics: Statistics?, _ error: Error?) -> Void
    /**
     - Parameters:
        - samples: sample array. Empty by default
        - error: error (optional)
    */
    public typealias SampleResultsHandler = (_ samples: [Sample], _ error: Error?) -> Void
    /**
     - Parameters:
        - serie: heartbeat serie.
        - error: error (optional)
    */
    public typealias HeartbeatDataHandler = (_ serie: HeartbeatSerie?, _ error: Error?) -> Void
    /**
     - Parameters:
        - summaries: summary array. Empty by default
        - error: error (optional)
    */
    public typealias ActivitySummaryCompletionHandler = (_ summaries: [ActivitySummary], _ error: Error?) -> Void
    /**
     - Parameters:
        - sources: source array. Empty by default
        - error: error (optional)
    */
    public typealias SourceCompletionHandler =  (_ sources: [Source], _ error: Error?) -> Void
    /**
     - Parameters:
        - correlations: correlation array. Empty by default
        - error: error (optional)
    */
    public typealias CorrelationCompletionHandler =  (_ correlations: [Correlation], _ error: Error?) -> Void

    typealias ActivitySummaryUpdateHanlder = (
        HKActivitySummaryQuery, [HKActivitySummary]?, Error?
    ) -> Void
    typealias AnchoredObjectQueryHandler = (
        HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?
    ) -> Void
    typealias HKStatisticsCollectionHandler = (
        HKStatisticsCollection?, Error?
    ) -> Void

    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Queries user's characteristics.
     - Throws: `HealthKitError.notAvailable``
     - Returns: **Characteristics** characteristics
     */
    public func characteristicsQuery() throws -> Characteristic {
        let biologicalSex = try healthStore.biologicalSex()
        let birthday = try healthStore.dateOfBirthComponents()
        let bloodType = try healthStore.bloodType()
        let skinType = try healthStore.fitzpatrickSkinType()
        return Characteristic(
            biologicalSex: biologicalSex,
            birthday: birthday,
            bloodType: bloodType,
            skinType: skinType
        )
    }
    /**
     Queries statistics.
     - Parameter type: **ObjectType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter completionHandler: returns a block with statistics
     */
    public func statisticsQuery<T>(
        type: T,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping StatisticsCompeltionHandler
    ) where T: ObjectType {
        guard let quantityType = type.original as? HKQuantityType else {
            completionHandler(
                nil,
                HealthKitError.invalidType("\(type) can not be represented as HKQuantityType")
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
        let resultsHandler: HKStatisticsCollectionHandler = { (data, error) in
            guard
                error == nil,
                let result = data
            else {
                enumerationBlock(nil, error)
                return
            }
            result.enumerateStatistics(from: enumerateFrom, to: enumerateTo) { (data, stop) in
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
     Queries samples.
     - Parameter type: **ObjectType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     */
    public func sampleQuery<T>(
        type: T,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping SampleResultsHandler
    ) where T: ObjectType {
        guard let sampleType = type.original as? HKSampleType else {
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
                let result = data
            else {
                resultsHandler([], error)
                return
            }
            var samples = [Sample]()
            for element in result {
                do {
                    let sample = try element.parsed()
                    samples.append(sample)
                } catch {
                    continue
                }
            }
            resultsHandler(samples, nil)
        }
        healthStore.execute(query)
    }
    /**
     Queries heartbeat series.
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter dataHandler: returns a block with heartbeat serie
     */
    @available(iOS 13.0, *)
    public func heartbeatSeriesQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        dataHandler: @escaping HeartbeatDataHandler
    ) {
        guard let sampleType = SeriesType.heartbeatSeries.original else {
            dataHandler(
                nil,
                HealthKitError.invalidType(
                    "ObjectType.heartbeatSeries can not be represented as HKSampleType"
                )
            )
            return
        }
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { [self] (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                dataHandler(nil, error)
                return
            }
            for element in result {
                if let seriesSample = element as? HKHeartbeatSeriesSample {
                    var ibiArray = [Double]()
                    var indexes = [Int]()
                    let heartbeatSeriesQuery = HKHeartbeatSeriesQuery(
                        heartbeatSeries: seriesSample
                    ) { (query, timeSinceSeriesStart, precededByGap, done, error) in
                        guard error == nil else {
                            dataHandler(nil, error)
                            return
                        }
                        ibiArray.append(timeSinceSeriesStart)
                        if ibiArray.contains(timeSinceSeriesStart) && precededByGap {
                            if let firstIndex = ibiArray.firstIndex(of: timeSinceSeriesStart) {
                                indexes.append(firstIndex)
                            }
                        }
                        if done {
                            let serie = HeartbeatSerie(
                                ibiArray: ibiArray,
                                indexArray: indexes
                            )
                            dataHandler(serie, nil)
                        }
                    }
                    healthStore.execute(heartbeatSeriesQuery)
                }
            }
        }
        healthStore.execute(query)
    }
    /**
     Queries activity summary.
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     - Parameter completionHandler: returns a block with activity summary array
     */
    public func queryActivitySummary(
        predicate: NSPredicate? = .allSamples,
        monitorUpdates: Bool = false,
        completionHandler: @escaping ActivitySummaryCompletionHandler
    ) {
        let resultsHandler: ActivitySummaryUpdateHanlder = { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler([], error)
                return
            }
            var summaries = [ActivitySummary]()
            for element in result {
                do {
                    let summary = try ActivitySummary(activitySummary: element)
                    summaries.append(summary)
                } catch {
                    continue
                }
            }
            completionHandler(summaries, nil)
        }
        let query = HKActivitySummaryQuery(predicate: predicate, resultsHandler: resultsHandler)
        if monitorUpdates {
            query.updateHandler = resultsHandler
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
    public func anchoredObjectQuery<T>(
        type: T,
        predicate: NSPredicate? = .allSamples,
        anchor: HKQueryAnchor? = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor)),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping SampleResultsHandler
    ) where T: ObjectType {
        guard let sampleType = type.original as? HKSampleType else {
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
                let result = data
            else {
                completionHandler([], error)
                return
            }
            var samples = [Sample]()
            for element in result {
                do {
                    let sample = try element.parsed()
                    samples.append(sample)
                } catch {
                    continue
                }
            }
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
    /**
     Queries sources.
     - Parameter type: **ObjectType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter completionHandler: returns a block with samples
     */
    public func sourceQuery<T>(
        type: T,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping SourceCompletionHandler
    ) where T: ObjectType {
        guard let sampleType = type.original as? HKSampleType else {
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
    /**
     Queries correlation.
     - Parameter type: **CorrelationType** type
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter typePredicates: **NSPredicate** type predicates (otpional). Nil by default
     - Parameter completionHandler: returns a block with samples
     */
    public func correlationQuery<T>(
        type: CorrelationType,
        predicate: NSPredicate? = .allSamples,
        typePredicates: [T : NSPredicate]? = nil,
        completionHandler: @escaping CorrelationCompletionHandler
    ) where T: ObjectType {
        guard let correlationType = type.original else {
            completionHandler(
                [],
                HealthKitError.invalidType(
                    "\(type) can not be represented as HKSampleType"
                )
            )
            return
        }
        var samplePredicates = [HKSampleType: NSPredicate]()
        if let predicates = typePredicates {
            for (key, value) in predicates {
                if let sampleType = key.original as? HKSampleType {
                    samplePredicates[sampleType] = value
                }
            }
        }
        let query = HKCorrelationQuery(
            type: correlationType,
            predicate: predicate,
            samplePredicates: samplePredicates
        ) { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler([], error)
                return
            }
            var correlations = [Correlation]()
            for element in result {
                do {
                    let correlation = try Correlation(correlation: element)
                    correlations.append(correlation)
                } catch {
                    continue
                }
            }
            completionHandler(correlations, nil)
        }
        healthStore.execute(query)
    }
}
