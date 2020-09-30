import Foundation
import HealthKit

public class HealthKitReader {
    public typealias ActivitySummaryQueryHanlder = (
        HKActivitySummaryQuery, [HKActivitySummary]?, Error?
    ) -> Void
    public typealias AnchoredObjectQueryHandler = (
        HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?
    ) -> Void
    public typealias HKStatisticsCollectionHandler = (
        HKStatisticsCollection?, Error?
    ) -> Void

    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    public func requestAuthorization(
        toRead: [HealthKitType],
        completionHandler: @escaping (Bool, Error?) -> Void
    ) {
        var setOfReadTypes = Set<HKObjectType>()
        for type in toRead {
            guard let objectType = type.rawValue else {
                completionHandler(
                    false,
                    HealthKitError.invalidType(
                        "Type \(type) has not HKObjectType representation"
                    )
                )
                return
            }
            setOfReadTypes.insert(objectType)
        }
        healthStore.requestAuthorization(
            toShare: Set(),
            read: setOfReadTypes,
            completion: completionHandler
        )
    }
    public func preferredUnits(
        for quantityTypes: [HealthKitType],
        completionHandler: @escaping ([String: String], Error?) -> Void
    ) {
        var setOfTypes = Set<HKQuantityType>()
        for type in quantityTypes {
            guard let objectType = type.rawValue as? HKQuantityType else {
                completionHandler(
                    [:],
                    HealthKitError.invalidType(
                        "Type \(type) has not HKQuantityType representation"
                    )
                )
                return
            }
            setOfTypes.insert(objectType)
        }
        healthStore.preferredUnits(for: setOfTypes) { (dictionary, error) in
            let mapped = dictionary.map { ($0.key.identifier, $0.value.unitString) }
            let dictionary = Dictionary(uniqueKeysWithValues: mapped)
            completionHandler(dictionary, error)
        }
    }
    public func characteristicsQuery() throws -> Characteristics {
        let biologicalSex = try healthStore.biologicalSex()
        let birthday = try healthStore.dateOfBirthComponents()
        let bloodType = try healthStore.bloodType()
        let skinType = try healthStore.fitzpatrickSkinType()
        return Characteristics(
            biologicalSex: biologicalSex,
            birthday: birthday,
            bloodType: bloodType,
            skinType: skinType
        )
    }
    public func statisticsQuery(
        type: HealthKitType,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping (Statistics?, Error?) -> Void
    ) {
        guard let quantityType = type.rawValue as? HKQuantityType else {
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
    public func statisticsCollectionQuery(
        type: HealthKitType,
        quantitySamplePredicate: NSPredicate? = .allSamples,
        anchorDate: Date,
        enumerateFrom: Date,
        enumerateTo: Date,
        intervalComponents: DateComponents,
        monitorUpdates: Bool = false,
        enumerationBlock: @escaping (Statistics?, Error?) -> Void
    ) {
        guard let quantityType = type.rawValue as? HKQuantityType else {
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
    public func sampleQuery(
        type: HealthKitType,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping ([Sample], Error?) -> Void
    ) {
        guard let sampleType = type.rawValue as? HKSampleType else {
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
    @available(iOS 13.0, *)
    public func heartbeatSeriesQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor],
        limit: Int = HKObjectQueryNoLimit,
        dataHandler: @escaping (HeartbeatSerie?, Error?) -> Void
    ) {
        guard let sampleType = HealthKitType.heartbeatSeries.rawValue as? HKSampleType else {
            dataHandler(
                nil,
                HealthKitError.invalidType(
                    "HealthKitType.heartbeatSeries can not be represented as HKSampleType"
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
    public func queryActivitySummary(
        predicate: NSPredicate? = .allSamples,
        monitorUpdates: Bool = false,
        completionHandler: @escaping ([ActivitySummary], Error?) -> Void
    ) {
        let resultsHandler: ActivitySummaryQueryHanlder = { (_, data, error) in
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
    public func anchoredObjectQuery(
        type: HealthKitType,
        predicate: NSPredicate? = .allSamples,
        anchor: HKQueryAnchor? = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor)),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping ([Sample], Error?) -> Void
    ) {
        guard let sampleType = type.rawValue as? HKSampleType else {
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
    public func sourceQuery(
        type: HealthKitType,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping ([Source], Error?) -> Void
    ) {
        guard let sampleType = type.rawValue as? HKSampleType else {
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
    public func correlationQuery(
        type: HealthKitType,
        predicate: NSPredicate? = .allSamples,
        typePredicates: [HealthKitType : NSPredicate]?,
        completionHandler: @escaping ([Correlation], Error?) -> Void
    ) {
        guard let correlationType = type.rawValue as? HKCorrelationType else {
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
                if let sampleType = key.rawValue as? HKSampleType {
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
