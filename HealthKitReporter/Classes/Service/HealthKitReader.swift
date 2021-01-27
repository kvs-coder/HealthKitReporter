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
     Gets user's characteristics.
     - Throws: `HealthKitError.notAvailable``
     - Returns: **Characteristics** characteristics
     */
    public func characteristics() -> Characteristic {
        let biologicalSex = try? healthStore.biologicalSex()
        let birthday = try? healthStore.dateOfBirthComponents()
        let bloodType = try? healthStore.bloodType()
        let skinType = try? healthStore.fitzpatrickSkinType()
        let wheelchairUse = try? healthStore.wheelchairUse()
        if #available(iOS 14.0, *) {
            let activityMoveMode = try? healthStore.activityMoveMode()
            return Characteristic(
                biologicalSex: biologicalSex,
                birthday: birthday,
                bloodType: bloodType,
                skinType: skinType,
                wheelchairUse: wheelchairUse,
                activityMoveMode: activityMoveMode
            )
        } else {
            return Characteristic(
                biologicalSex: biologicalSex,
                birthday: birthday,
                bloodType: bloodType,
                skinType: skinType,
                wheelchairUse: wheelchairUse
            )
        }
    }
    /**
     Queries quantity types.
     - Parameter type: **QuantityType** types
     - Parameter unit: **String** unit
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
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
    ) throws -> SampleQuery {
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
    /**
     Queries category types.
     - Parameter type: **CategoryType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
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
    ) throws -> SampleQuery {
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
    /**
     Queries workouts.
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
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
    ) throws -> SampleQuery {
        let workoutType = WorkoutType.workoutType
        guard let type = workoutType.original as? HKWorkoutType else {
            throw HealthKitError.invalidType(
                "\(workoutType) can not be represented as HKWorkoutType"
            )
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
    /**
     Queries correlations.
     - Parameter type: **CorrelationType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func correlationQuery(
        type: CorrelationType,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping CorrelationResultsHandler
    ) throws -> SampleQuery {
        guard let correlationType = type.original as? HKCorrelationType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKWorkoutType"
            )
        }
        let query = HKSampleQuery(
            sampleType: correlationType,
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
            let samples = Correlation.collect(
                results: results
            )
            resultsHandler(samples, nil)
        }
        return query
    }
    /**
     Queries electrocardiogram.
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
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
    ) throws -> SampleQuery {
        return try ElectrocardiogramRetriever().makeElectrocardiogramQuery(
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            resultsHandler: resultsHandler
        )
    }
    /**
     Queries electrocardiogram.
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter dataHandler: returns a block with voltage measurement for each
     iteration until **done**  is True.
     - Throws: HealthKitError.invalidType
     */
    @available(iOS 14.0, *)
    public func electrocardiogramVoltageMeasurementQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        dataHandler: @escaping ElectrocardiogramVoltageMeasurementDataHandler
    ) throws -> SampleQuery {
        return try ElectrocardiogramRetriever().electrocardiogramVoltageMeasurementQuery(
            healthStore: healthStore,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            dataHandler: dataHandler
        )
    }
    /**
     Queries samples. If samples are quantity types, the SI for units will be used.
     - Parameter type: **SampleType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    @available(
        iOS,
        deprecated: 11,
        message: "Use special functions for fetching Quantity/Category/Workout samples. For Quantity Samples will return with SI units"
    )
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
    ) throws -> SampleQuery {
        guard let sampleType = type.original as? HKSampleType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKSampleType"
            )
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
        return query
    }
    /**
     Queries statistics.
     - Parameter type: **ObjectType** types
     - Parameter unit: **String** unit
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter completionHandler: returns a block with statistics
     - Throws: HealthKitError.invalidType
     */
    public func statisticsQuery(
        type: QuantityType,
        unit: String,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping StatisticsCompeltionHandler
    ) throws -> StatisticsQuery {
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
     - Throws: HealthKitError.invalidType
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
    ) throws -> StatisticsCollectionQuery {
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
    /**
     Queries heartbeat series.
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter dataHandler: returns a block with heartbeat serie for each
     iteration until **done** of **HeartbeatSerie**  is True.
     - Throws: HealthKitError.invalidType
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
    ) throws -> SampleQuery {
        return try SeriesSampleRetriever().makeHeartbeatSeriesQuery(
            healthStore: healthStore,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            dataHandler: dataHandler
        )
    }
    /**
     Queries workout route.
     - Requires: CLLocation permissions:
     “Privacy - Location Always and When In Use Usage Description”
     and “Privacy - Location When In Use Usage Description”.
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter dataHandler: returns a block with heartbeat serie for each
     iteration until **done** of **WorkoutRoute**  is True.
     - Throws: HealthKitError.invalidType
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
    ) throws -> SampleQuery {
        return try SeriesSampleRetriever().makeWorkoutRouteQuery(
            healthStore: healthStore,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            dataHandler: dataHandler
        )
    }
    /**
     Queries activity summary.
     - Parameter predicate: **NSPredicate** predicate (otpional). nil by default
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     - Parameter completionHandler: returns a block with activity summary array
     */
    public func queryActivitySummary(
        predicate: NSPredicate? = nil,
        monitorUpdates: Bool = false,
        completionHandler: @escaping ActivitySummaryCompletionHandler
    ) -> ActivitySummaryQuery {
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
        return query
    }
    /**
     Queries objects (with anchors).
     - Parameter type: **SampleType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter anchor: **HKQueryAnchor** anchor. HKAnchoredObjectQueryNoAnchor by default
     - Parameter limit: **Int** anchor. HKObjectQueryNoLimit by default
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     - Parameter completionHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func anchoredObjectQuery(
        type: SampleType,
        predicate: NSPredicate? = .allSamples,
        anchor: HKQueryAnchor? = HKQueryAnchor(
            fromValue: Int(HKAnchoredObjectQueryNoAnchor)
        ),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping SampleResultsHandler
    ) throws -> AnchoredObjectQuery {
        guard let sampleType = type.original as? HKSampleType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKSampleType"
            )
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
        return query
    }
    /**
     Queries sources.
     - Parameter type: **SampleType** types
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter completionHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func sourceQuery(
        type: SampleType,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping SourceCompletionHandler
    ) throws -> SourceQuery {
        guard let sampleType = type.original as? HKSampleType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKSampleType"
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
    /**
     Queries correlation.
     - Parameter type: **CorrelationType** type
     - Parameter predicate: **NSPredicate** predicate (otpional). allSamples by default
     - Parameter typePredicates: type predicates (otpional). Key is the type
     identifier **String**  and value is **NSPredicate**. Nil by default
     - Parameter completionHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func correlationQuery(
        type: CorrelationType,
        predicate: NSPredicate? = .allSamples,
        typePredicates: [String: NSPredicate]? = nil,
        completionHandler: @escaping CorrelationCompletionHandler
    ) throws -> CorrelationQuery {
        guard let correlationType = type.original as? HKCorrelationType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKCorrelationType"
            )
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
        return query
    }
}
