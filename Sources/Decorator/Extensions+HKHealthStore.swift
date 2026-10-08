//
//  Extensions+HKHealthStore.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

extension HKHealthStore {
    /// The stored sample with this uuid; relationships and attachments belong to persisted objects
    func storedSample(
        of type: ObjectType,
        uuid: String,
        completion: @escaping (HKSample?, Error?) -> Void
    ) {
        guard
            let sampleType = type.original as? HKSampleType,
            let identifier = UUID(uuidString: uuid)
        else {
            completion(nil, HealthKitError.invalidValue("Invalid sample \(type) \(uuid)"))
            return
        }
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: HKQuery.predicateForObject(with: identifier),
            limit: 1,
            sortDescriptors: nil
        ) { _, samples, error in
            guard let sample = samples?.first else {
                completion(nil, error ?? HealthKitError.invalidIdentifier("No \(type) sample \(uuid)"))
                return
            }
            completion(sample, nil)
        }
        execute(query)
    }
}
