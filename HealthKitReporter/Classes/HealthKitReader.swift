import Foundation
import HealthKit

enum HealthKitError: Error {
    case notAvailable(String = "HealthKit data is not available")
    case unknown(String = "Unknown")
    case invalidType(String = "Invalid type")
    case invalidOption(String = "Invalid option")
    case invalidValue(String = "Invalid value")
}

public class HealthKitReader {
    private let healthStore: HKHealthStore

    public init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    public func authorizeHealthKit(
        typesToRead: [HealthKitType],
        completionHandler: @escaping (Bool, Error?) -> Void
    ) throws {
        var setOfReadTypes = Set<HKObjectType>()
        for type in typesToRead {
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
    public func queryCharacteristics() throws -> Characteristics {
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
    public func queryStatistics(
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
            let statistics = Statistics(statistics: result)
            completionHandler(statistics, nil)
        }
        healthStore.execute(query)
    }
    public func querySamples(
        type: HealthKitType,
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor],
        limit: Int = HKObjectQueryNoLimit,
        completionHandler: @escaping ([Sample], Error?) -> Void
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
                completionHandler([], error)
                return
            }
            var samples = [Sample]()
            for element in result {
                if let quantitySample = element as? HKQuantitySample {
                    let sample = Quantitiy(quantitySample: quantitySample)
                    samples.append(sample)
                }
                if let categorySample = element as? HKCategorySample {
                    let sample = Category(categorySample: categorySample)
                    samples.append(sample)
                }
                if #available(iOS 14.0, *) {
                    if let electrocardiogram = element as? HKElectrocardiogram {
                        let sample = Electrocardiogram(electrocardiogram: electrocardiogram)
                        samples.append(sample)
                    }
                }
            }
            completionHandler(samples, nil)
        }
        healthStore.execute(query)
    }
    @available(iOS 13.0, *)
    public func querySeries(
        type: HealthKitType,
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor],
        limit: Int = HKObjectQueryNoLimit,
        completionHandler: @escaping ([Serie], Error?) -> Void
    ) throws {
        guard let sampleType = type.rawValue as? HKSampleType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKSampleType")
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
                completionHandler([], error)
                return
            }
            var series = [Serie]()
            for element in result {
                if let seriesSample = element as? HKHeartbeatSeriesSample {
                    var ibiArray = [Double]()
                    var indexes = [Int]()
                    let heartbeatSeriesQuery = HKHeartbeatSeriesQuery(
                        heartbeatSeries: seriesSample
                    ) { (query, timeSinceSeriesStart, precededByGap, done, error) in
                        guard error == nil else {
                            completionHandler([], error)
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
                            series.append(serie)
                        }
                    }
                    healthStore.execute(heartbeatSeriesQuery)
                }
            }
            completionHandler(series, nil)
        }
        healthStore.execute(query)
    }
    public func queryActivitySummary(
        predicate: NSPredicate,
        completionHandler: @escaping ([ActivitySummary], Error?) -> Void
    ) {
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, data, error) in
            guard
                error == nil,
                let result = data
                else {
                completionHandler([], error)
                return
            }
            var summaries = [ActivitySummary]()
            for element in result {
                let activitySummary = ActivitySummary(activitySummary: element)
                summaries.append(activitySummary)
            }
            completionHandler(summaries, nil)
        }
        healthStore.execute(query)
    }
}
