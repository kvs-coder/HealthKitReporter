import Foundation
import HealthKit

enum HealthKitError: Error {
    case notAvailable(String = "HealthKit data is not available")
    case invalidType(String = "Invalid type")
    case invalidOption(String = "Invalid option")
    case invalidValue(String = "Invalid value")
}


public class HealthKitReporter {
    private let healthStore: HKHealthStore

    public init() throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable()
        }
        self.healthStore = HKHealthStore()
    }

    public func authorizeHealthKit(
        typesToRead: Set<HKObjectType>,
        typesToWrite: Set<HKSampleType>,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) {
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead, completion: completionHandler)
    }
    public func queryCharacteristics() throws -> Characteristics {
        let biologicalSex = try healthStore
            .biologicalSex()
            .biologicalSex
            .string
        let birthday = try healthStore
            .dateOfBirthComponents()
            .date?
            .formatted(with: Date.yyyyMMdd)
        let bloodType = try healthStore
            .bloodType()
            .bloodType
            .string
        let skinType = try healthStore
            .fitzpatrickSkinType()
            .skinType
            .string
        return Characteristics(
            biologicalSex: biologicalSex,
            birthday: birthday,
            bloodType: bloodType,
            skinType: skinType
        )
    }
    public func queryStatistics(
        type: HKSampleType,
        start: Date,
        end: Date,
        options: HKQueryOptions,
        completionHandler: @escaping (Statistics?, Error?) -> Void
    ) throws {
        guard let quantityType = type as? HKQuantityType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKQuantityType")
        }
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: options
        )
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: quantityType.statisticsOptions) { (_, data, error) in
                guard
                    error == nil,
                    let result = data
                    else {
                        completionHandler(nil, error)
                        return
                }
                do {
                    let (value, unit) = try result.parsed()
                    let statistics = Statistics(
                        identifier: result.quantityType.identifier,
                        value: value,
                        startDate: result.startDate.formatted(with: Date.yyyyMMddTHHmmssZZZZZ),
                        endDate: result.endDate.formatted(with: Date.yyyyMMddTHHmmssZZZZZ),
                        unit: unit)
                    completionHandler(statistics, nil)
                } catch {
                    completionHandler(nil, error)
                }
        }
        healthStore.execute(query)
    }
    public func querySamples(
        type: HKSampleType,
        start: Date,
        end: Date,
        options: HKQueryOptions,
        completionHandler: @escaping ([Sample], Error?) -> Void
    ) {
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: options
        )
        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: sortDescriptors) { (_, samples, error) in
                guard error == nil else {
                    logError(error)
                    return
                }
                logDebug("\(recent) last upload: \(lastUpload)")
                if let samples = samples {
                    if #available(iOS 13.0, *) {
                        for sample in samples {
                            if let series = sample as? HKHeartbeatSeriesSample {
                                self.queryHeartbeat(series: series, completionHandler: completionHandler)
                            }
                        }
                    }
                    parser.parse(samples: samples, completion: completionHandler)
                }
        }
        healthStore.execute(query)
    }
}
