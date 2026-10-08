//
//  HealthKitWriter.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import HealthKit

/// **HealthKitWriter** class for HK writing operations
public class HealthKitWriter {
    let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Checks authorization for writing Objects in HK.
     - Parameter type: **ObjectType** type to check
     - Throws: `HealthKitError.notAvailable` `HealthKitError.invalidType`
     - Returns: true if allowed to write and false if  not
     */
    public func isAuthorizedToWrite(type: ObjectType) throws -> Bool {
        guard let objectType = type.hkObjectType else {
            throw HealthKitError.invalidType("Invalid type: \(type)")
        }
        let status = healthStore.authorizationStatus(for: objectType)
        switch status {
        case .notDetermined, .sharingDenied:
            return false
        case .sharingAuthorized:
            return true
        @unknown default:
            throw HealthKitError.notAvailable(
                "Unknown authorization status \(status.rawValue) for \(objectType.identifier)"
            )
        }
    }
    /**
     Adds category samples to a saved workout
     - Parameter samples: **Category** samples
     - Parameter from: **Device** device the samples come from (optional).
     Replaces each sample's device when set
     - Parameter workout: **Workout** workout already stored in HealthKit, looked up by its uuid
     - Parameter completion: block notifies about operation status
     */
    public func addCategory(
        _ samples: [Category],
        from device: Device?,
        to workout: Workout,
        completion: @escaping StatusCompletionBlock
    ) {
        let categorySamples: [HKSample]
        do {
            categorySamples = try samples.map {
                try $0.copyWith(device: device).asOriginal()
            }
        } catch {
            completion(false, error)
            return
        }
        add(categorySamples, to: workout, completion: completion)
    }
    /**
     Adds quantity samples to a saved workout
     - Parameter samples: **Quantity** samples
     - Parameter from: **Device** device the samples come from (optional).
     Replaces each sample's device when set
     - Parameter workout: **Workout** workout already stored in HealthKit, looked up by its uuid
     - Parameter completion: block notifies about operation status
     */
    public func addQuantity(
        _ samples: [Quantity],
        from device: Device?,
        to workout: Workout,
        completion: @escaping StatusCompletionBlock
    ) {
        let quantitySamples: [HKSample]
        do {
            quantitySamples = try samples.map {
                try $0.copyWith(device: device).asOriginal()
            }
        } catch {
            completion(false, error)
            return
        }
        add(quantitySamples, to: workout, completion: completion)
    }
    /**
     Adds quantity samples to a saved workout
     - Parameter samples: **Quantity** samples
     - Parameter from: **Device** device the samples come from (optional)
     - Parameter workout: **Workout** workout
     - Parameter completion: block notifies about operation status
     */
    @available(*, deprecated, renamed: "addQuantity(_:from:to:completion:)")
    public func addQuantitiy(
        _ samples: [Quantity],
        from device: Device?,
        to workout: Workout,
        completion: @escaping StatusCompletionBlock
    ) {
        addQuantity(samples, from: device, to: workout, completion: completion)
    }
    /**
     Deletes a stored sample, looked up by its uuid and sample type.
     A sample that is not stored completes with HealthKitError.invalidIdentifier
     - Parameter sample: **Sample** sample read from HealthKit or saved with **save(sample:completion:)**
     - Parameter completion: block notifies about operation status
     */
    public func delete(
        sample: Sample,
        completion: @escaping StatusCompletionBlock
    ) {
        delete(samples: [sample], completion: completion)
    }
    /**
     Deletes stored samples at once, looked up by their uuids and sample types.
     Nothing is deleted when one of them is not stored;
     then the block carries HealthKitError.invalidIdentifier
     - Parameter samples: **Sample** samples read from HealthKit or saved with **save(samples:completion:)**
     - Parameter completion: block notifies about operation status
     */
    public func delete(
        samples: [Sample],
        completion: @escaping StatusCompletionBlock
    ) {
        var uuidsByType = [String: [String]]()
        for sample in samples {
            guard sample.identifier.objectType != nil else {
                completion(false, HealthKitError.invalidType("Invalid sample type: \(sample.identifier)"))
                return
            }
            uuidsByType[sample.identifier, default: []].append(sample.uuid)
        }
        let group = DispatchGroup()
        let lock = NSLock()
        var stored = [HKSample]()
        var lookupError: Error?
        for (identifier, uuids) in uuidsByType {
            guard let type = identifier.objectType else {
                continue
            }
            group.enter()
            StoredSampleRetriever().storedSamples(
                healthStore: healthStore,
                of: type,
                uuids: Array(Set(uuids))
            ) { samples, error in
                lock.lock()
                stored += samples
                lookupError = lookupError ?? error
                lock.unlock()
                group.leave()
            }
        }
        group.notify(queue: .global()) { [healthStore] in
            guard lookupError == nil, !stored.isEmpty else {
                completion(lookupError == nil, lookupError)
                return
            }
            healthStore.delete(stored, withCompletion: completion)
        }
    }
    /**
     Deletes objects of type with predicate
     - Parameter objectType: **ObjectType** type
     - Parameter predicate: **NSPredicate** predicate for deletion
     - Parameter completion: block notifies about deletion operation status
     */
    public func deleteObjects(
        of objectType: ObjectType,
        predicate: NSPredicate,
        completion: @escaping DeletionCompletionBlock
    ) {
        guard let type = objectType.hkObjectType else {
            completion(
                false,
                -1,
                HealthKitError.invalidType("Object type was invalid: \(objectType)")
            )
            return
        }
        healthStore.deleteObjects(of: type, predicate: predicate, withCompletion: completion)
    }
    /**
     Saves the created sample.
     Supports **Quantity**, **Category**, **Workout**, **Correlation**, **Audiogram**, **VisionPrescription**,
     **StateOfMind**, **ScoredAssessment** and **CDADocument**;
     any other sample completes with HealthKitError.invalidType.
     HealthKit gives the stored sample a new uuid, which the completion reports
     - Parameter sample: **Sample** sample
     - Parameter completion: block notifies about operation status and the uuid of the stored sample
     */
    public func save(
        sample: Sample,
        completion: @escaping SaveCompletionBlock
    ) {
        save(samples: [sample]) { success, uuids, error in
            completion(success, uuids.first, error)
        }
    }
    /**
     Saves samples at once; either all of them are stored or none.
     Supports the samples **save(sample:completion:)** supports
     - Parameter samples: **Sample** samples
     - Parameter completion: block notifies about operation status
     and the uuids of the stored samples, in order
     */
    public func save(
        samples: [Sample],
        completion: @escaping SamplesSaveCompletionBlock
    ) {
        do {
            let originals = try samples.map(original(of:))
            healthStore.save(originals) { success, error in
                completion(success, success ? originals.map(\.uuid.uuidString) : [], error)
            }
        } catch {
            completion(false, [], error)
        }
    }

    private func add(
        _ samples: [HKSample],
        to workout: Workout,
        completion: @escaping StatusCompletionBlock
    ) {
        StoredSampleRetriever().storedSample(
            healthStore: healthStore,
            of: WorkoutType.workoutType,
            uuid: workout.uuid
        ) { [healthStore] stored, error in
            guard let stored = stored as? HKWorkout else {
                completion(false, error)
                return
            }
            healthStore.add(samples, to: stored, completion: completion)
        }
    }

    private func original(of sample: Sample) throws -> HKSample {
        if #available(iOS 16.0, watchOS 9.0, *), let prescription = sample as? VisionPrescription {
            return try prescription.asOriginal()
        }
        if #available(iOS 18.0, watchOS 11.0, *) {
            if let stateOfMind = sample as? StateOfMind {
                return try stateOfMind.asOriginal()
            }
            if let assessment = sample as? ScoredAssessment {
                return try assessment.asOriginal()
            }
        }
        #if os(iOS)
        if let document = sample as? CDADocument {
            return try document.asOriginal()
        }
        #endif
        switch sample {
        case let quantity as Quantity:
            return try quantity.asOriginal()
        case let category as Category:
            return try category.asOriginal()
        case let workout as Workout:
            return try workout.asOriginal()
        case let correlation as Correlation:
            return try correlation.asOriginal()
        case let audiogram as Audiogram:
            return try audiogram.asOriginal()
        default:
            throw HealthKitError.invalidType(
                "\(type(of: sample)) can not be represented as HKSample"
            )
        }
    }
}
