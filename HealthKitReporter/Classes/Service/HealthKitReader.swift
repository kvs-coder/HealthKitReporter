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
    ) throws {
        var setOfReadTypes = Set<HKObjectType>()
        for type in toRead {
            guard let objectType = type.rawValue else {
                throw HealthKitError.invalidType(
                    "Type \(type) has not HKObjectType representation"
                )
            }
            setOfReadTypes.insert(objectType)
        }
        healthStore.requestAuthorization(
            toShare: Set(),
            read: setOfReadTypes,
            completion: completionHandler
        )
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
        predicate: NSPredicate,
        completionHandler: @escaping (Statistics?, Error?) -> Void
    ) throws {
        guard let quantityType = type.rawValue as? HKQuantityType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKQuantityType")
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
            let statistics = try? result.parsed()
            completionHandler(statistics, nil)
        }
        healthStore.execute(query)
    }
    public func statisticsCollectionQuery(
        type: HealthKitType,
        quantitySamplePredicate: NSPredicate?,
        anchorDate: Date,
        enumeratwFrom: Date,
        enumerateTo: Date,
        intervalComponents: DateComponents,
        monitorUpdates: Bool = false,
        enumerationBlock: @escaping (Statistics?, Error?) -> Void
    ) throws {
        guard let quantityType = type.rawValue as? HKQuantityType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKQuantityType")
        }
        let resultsHandler: HKStatisticsCollectionHandler = { (data, error) in
            guard
                error == nil,
                let result = data
            else {
                enumerationBlock(nil, error)
                return
            }
            result.enumerateStatistics(from: enumeratwFrom, to: enumerateTo) { (data, stop) in
                let statistics = try? data.parsed()
                enumerationBlock(statistics, nil)
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
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping ([Sample], Error?) -> Void
    ) throws {
        guard let sampleType = type.rawValue as? HKSampleType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKSampleType")
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
            let parser = HealthKitParser()
            for element in result {
                if let sample = parser.parse(element: element) {
                    samples.append(sample)
                }
            }
            resultsHandler(samples, nil)
        }
        healthStore.execute(query)
    }
    @available(iOS 13.0, *)
    public func heartbeatSeriesQuery(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int = HKObjectQueryNoLimit,
        dataHandler: @escaping (HeartbeatSerie?, Error?) -> Void
    ) throws {
        guard let sampleType = HealthKitType.heartbeatSeries.rawValue as? HKSampleType else {
            throw HealthKitError.invalidType(
                "HealthKitType.heartbeatSeries can not be represented as HKSampleType"
            )
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
        predicate: NSPredicate?,
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
            let summaries = result.map { ActivitySummary(activitySummary: $0) }
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
        predicate: NSPredicate?,
        anchor: HKQueryAnchor? = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor)),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping ([Sample], Error?) -> Void
    ) throws {
        guard let sampleType = type.rawValue as? HKSampleType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKSampleType")
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
            let parser = HealthKitParser()
            for element in result {
                if let sample = parser.parse(element: element) {
                    samples.append(sample)
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
        predicate: NSPredicate?,
        completionHandler: @escaping ([Source], Error?) -> Void
    ) throws {
        guard let sampleType = type.rawValue as? HKSampleType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKSampleType")
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
        predicate: NSPredicate?,
        typePredicates: [HealthKitType : NSPredicate]?,
        completionHandler: @escaping ([Correlation], Error?) -> Void
    ) throws {
        guard let correlationType = type.rawValue as? HKCorrelationType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKSampleType")
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
            let parser = HealthKitParser()
            for element in result {
                var correlation = Correlation(correlation: element)
                for object in element.objects {
                    if let parsed = parser.parse(element: object) as? Quantitiy {
                        correlation.quantitySamples.append(parsed)
                    }
                    if let parsed = parser.parse(element: object) as? Category {
                        correlation.categorySamples.append(parsed)
                    }
                }
                correlations.append(correlation)
            }
        }
        healthStore.execute(query)
    }
}
