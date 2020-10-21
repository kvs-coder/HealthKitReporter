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
        - samples: sample array. Empty by default
        - error: error (optional)
    */
    public typealias SampleResultsHandler = (_ samples: [Sample], _ error: Error?) -> Void
    /**
     - Parameters:
        - samples: sample array. Empty by default
        - error: error (optional)
    */
    public typealias QunatityResultsHandler = (_ samples: [Quantity], _ error: Error?) -> Void
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
    private let quantitySampleRetriever = QuantitySampleRetriever()

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
