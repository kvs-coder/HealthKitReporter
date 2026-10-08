//
//  StoredSampleRetriever.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// Finds samples stored in HealthKit by their uuids;
/// deletions, relationships and attachments act on stored objects
class StoredSampleRetriever {
    /// The stored samples of one type with these uuids; any uuid that is not stored fails the lookup
    func storedSamples(
        healthStore: HKHealthStore,
        of type: ObjectType,
        uuids: [String],
        completion: @escaping ([HKSample], Error?) -> Void
    ) {
        let identifiers = uuids.compactMap(UUID.init(uuidString:))
        guard
            let sampleType = type.hkObjectType as? HKSampleType,
            identifiers.count == uuids.count
        else {
            completion([], HealthKitError.invalidValue("Invalid samples \(type) \(uuids)"))
            return
        }
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: HKQuery.predicateForObjects(with: Set(identifiers)),
            limit: identifiers.count,
            sortDescriptors: nil
        ) { _, samples, error in
            let samples = samples ?? []
            guard error == nil, samples.count == Set(identifiers).count else {
                completion([], error ?? HealthKitError.invalidIdentifier("No \(type) samples \(uuids)"))
                return
            }
            completion(samples, nil)
        }
        healthStore.execute(query)
    }
    /// The stored sample of the type with this uuid
    func storedSample(
        healthStore: HKHealthStore,
        of type: ObjectType,
        uuid: String,
        completion: @escaping (HKSample?, Error?) -> Void
    ) {
        storedSamples(healthStore: healthStore, of: type, uuids: [uuid]) { samples, error in
            completion(samples.first, error)
        }
    }
}
