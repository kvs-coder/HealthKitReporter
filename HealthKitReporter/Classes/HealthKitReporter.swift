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
        type: HKSampleType,
        predicate: NSPredicate,
        completionHandler: @escaping (Statistics?, Error?) -> Void
    ) throws {
        guard let quantityType = type as? HKQuantityType else {
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
        type: HKSampleType,
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor],
        limit: Int = HKObjectQueryNoLimit,
        completionHandler: @escaping ([Sample], Error?) -> Void
    ) {
        let query = HKSampleQuery(
            sampleType: type,
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
                    let sample = Sample(quantitySample: quantitySample)
                    samples.append(sample)
                }
                if let categorySample = element as? HKCategorySample {
                    let sample = Sample(categorySample: categorySample)
                    samples.append(sample)
                }
            }
            completionHandler(samples, nil)
        }
        healthStore.execute(query)
    }
}
