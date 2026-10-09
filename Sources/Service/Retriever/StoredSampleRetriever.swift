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
        do {
            healthStore.execute(try makeStoredSamplesQuery(of: type, uuids: uuids, completion: completion))
        } catch {
            completion([], error)
        }
    }
    /// The query looking up the stored samples of one type with these uuids, built but not executed
    func makeStoredSamplesQuery(
        of type: ObjectType,
        uuids: [String],
        completion: @escaping ([HKSample], Error?) -> Void
    ) throws -> HKSampleQuery {
        let identifiers = uuids.compactMap(UUID.init(uuidString:))
        guard
            let sampleType = type.hkObjectType as? HKSampleType,
            identifiers.count == uuids.count
        else {
            throw HealthKitError.invalidValue("Invalid samples \(type) \(uuids)")
        }
        return HKSampleQuery(
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
