//
//  HealthKitReader.swift
//  HealthKitReader
//
//  Created by Victor on 23.09.20.
//

import Foundation
import HealthKit

typealias ActivitySummaryUpdateHanlder = (
    HKActivitySummaryQuery, [HKActivitySummary]?, Error?
) -> Void
typealias HKStatisticsCollectionHandler = (
    HKStatisticsCollection?, Error?
) -> Void
typealias AnchoredObjectQueryHandler = (
    HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?
) -> Void
typealias StatisticsCollectionHandler = (
    HKStatisticsCollection?, Error?
) -> Void

/// **HealthKitReader** class for HK reading operations
public class HealthKitReader {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Queries user's characteristics.
     - Throws: `HealthKitError.notAvailable``
     - Returns: **Characteristics** characteristics
     */
    public func characteristicsQuery() -> Characteristic {
        let biologicalSex = try? healthStore.biologicalSex()
        let birthday = try? healthStore.dateOfBirthComponents()
        let bloodType = try? healthStore.bloodType()
        let skinType = try? healthStore.fitzpatrickSkinType()
        return Characteristic(
            biologicalSex: biologicalSex,
            birthday: birthday,
            bloodType: bloodType,
            skinType: skinType
        )
    }
    /**
     Queries quantity types.
     - Parameter type: **QuantityType** types
     - Parameter unit: **String** unit
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     */
    public func quantityQuery(
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
        do {
            let query = try QuantitySampleRetriever().makeSampleQuery(
                type: type,
                unit: unit,
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit,
                resultsHandler: resultsHandler
            )
            healthStore.execute(query)
        } catch {
            resultsHandler([], error)
        }
    }
    /**
     Queries category types.
     - Parameter type: **CategoryType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     */
    public func categoryQuery(
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
        do {
            let query = try CategorySampleRetriever().makeSampleQuery(
                type: type,
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit,
                resultsHandler: resultsHandler
            )
            healthStore.execute(query)
        } catch {
            resultsHandler([], error)
        }
    }
    /**
     Queries workouts.
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     */
    public func workoutQuery(
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
        do {
            let query = try WorkoutRetriever().makeSampleQuery(
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit,
                resultsHandler: resultsHandler
            )
            healthStore.execute(query)
        } catch {
            resultsHandler([], error)
        }
    }
    /**
     Queries electrocardiogram.
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     */
    @available(iOS 14.0, *)
    public func electrocardiogramQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping ElectrocardiogramResultsHandler
    ) {
        do {
            let query = try ElectrocardiogramRetriever().makeSampleQuery(
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit,
                resultsHandler: resultsHandler
            )
            healthStore.execute(query)
        } catch {
            resultsHandler([], error)
        }
    }
    /**
     Queries samples. If samples are quantity types, the SI for units will be used.
     - Parameter type: **SampleType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     */
    public func sampleQuery(
        type: SampleType,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping SampleResultsHandler
    ) {
        guard let sampleType = type.original as? HKSampleType else {
            resultsHandler(
                nil,
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
        ) { (query, data, error) in
            guard
                error == nil,
                let result = data
            else {
                resultsHandler(
                    query,
                    [],
                    error
                )
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
            resultsHandler(
                query,
                samples,
                nil
            )
        }
        healthStore.execute(query)
    }
    /**
     Queries statistics.
     - Parameter type: **ObjectType** types
     - Parameter unit: **String** unit
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter completionHandler: returns a block with statistics
     */
    public func statisticsQuery(
        type: QuantityType,
        unit: String,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping StatisticsCompeltionHandler
    ) {
        do {
            let query = try QuantitySampleRetriever().makeStatisticsQuery(
                type: type,
                unit: unit,
                predicate: predicate,
                completionHandler: completionHandler
            )
            healthStore.execute(query)
        } catch {
            completionHandler(nil, error)
        }
    }
    /**
     Queries statistics collection.
     - Parameter type: **QuantityType** types
     - Parameter unit: **String** unit
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
        unit: String,
        quantitySamplePredicate: NSPredicate? = .allSamples,
        anchorDate: Date,
        enumerateFrom: Date,
        enumerateTo: Date,
        intervalComponents: DateComponents,
        monitorUpdates: Bool = false,
        enumerationBlock: @escaping StatisticsCompeltionHandler
    ) {
        do {
            let query = try QuantitySampleRetriever().makeStatisticsCollectionQuery(
                type: type,
                unit: unit,
                quantitySamplePredicate: quantitySamplePredicate,
                anchorDate: anchorDate,
                enumerateFrom: enumerateFrom,
                enumerateTo: enumerateTo,
                intervalComponents: intervalComponents,
                monitorUpdates: monitorUpdates,
                enumerationBlock: enumerationBlock
            )
            healthStore.execute(query)
        } catch {
            enumerationBlock(nil, error)
        }
    }
    /**
     Queries heartbeat series.
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter dataHandler: returns a block with heartbeat serie for each
     iteration until **done** of **HeartbeatSerie**  is True.
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
        dataHandler: @escaping HeartbeatSeriesDataHandler
    ) {
        do {
            let query = try SeriesSampleRetriever().makeHeartbeatSeriesQuery(
                healthStore: healthStore,
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit,
                dataHandler: dataHandler
            )
            healthStore.execute(query)
        } catch {
            dataHandler(nil, error)
        }
    }
    /**
     Queries workout route.
     - Requires: CLLocation permissions
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter dataHandler: returns a block with heartbeat serie for each
     iteration until **done** of **WorkoutRoute**  is True.
     */
    public func workoutRouteQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        dataHandler: @escaping WorkoutRouteDataHandler
    ) {
        do {
            let query = try SeriesSampleRetriever().makeWorkoutRouteQuery(
                healthStore: healthStore,
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit,
                dataHandler: dataHandler
            )
            healthStore.execute(query)
        } catch {
            dataHandler(nil, error)
        }
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
     - Parameter type: **SampleType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter anchor: **HKQueryAnchor** anchor. HKAnchoredObjectQueryNoAnchor by default
     - Parameter limit: **Int** anchor. HKObjectQueryNoLimit by default
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     - Parameter completionHandler: returns a block with samples
     */
    public func anchoredObjectQuery(
        type: SampleType,
        predicate: NSPredicate? = .allSamples,
        anchor: HKQueryAnchor? = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor)),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping SampleResultsHandler
    ) {
        guard let sampleType = type.original as? HKSampleType else {
            completionHandler(
                nil,
                [],
                HealthKitError.invalidType(
                    "\(type) can not be represented as HKSampleType"
                )
            )
            return
        }
        let resultsHandler: AnchoredObjectQueryHandler = { (query, data, deletedObjects, anchor, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler(
                    query,
                    [],
                    error
                )
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
            completionHandler(
                query,
                samples,
                nil
            )
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
     - Parameter type: **SampleType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter completionHandler: returns a block with samples
     */
    public func sourceQuery(
        type: SampleType,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping SourceCompletionHandler
    ) {
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
     - Parameter typePredicates: type predicates (otpional). Key is the type
     identifier **String**  and value is **NSPredicate**. Nil by default
     - Parameter completionHandler: returns a block with samples
     */
    public func correlationQuery(
        type: CorrelationType,
        predicate: NSPredicate? = .allSamples,
        typePredicates: [String: NSPredicate]? = nil,
        completionHandler: @escaping CorrelationCompletionHandler
    ) {
        guard let correlationType = type.original as? HKCorrelationType else {
            completionHandler(
                [],
                HealthKitError.invalidType(
                    "\(type) can not be represented as HKCorrelationType"
                )
            )
            return
        }
        let query = HKCorrelationQuery(
            type: correlationType,
            predicate: predicate,
            samplePredicates: typePredicates?.sampleTypePredicates
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
