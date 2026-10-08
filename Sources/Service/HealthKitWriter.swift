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
            throw HealthKitError.notAvailable("Invalid status")
        }
    }
    /**
     Adds category samples to a saved workout
     - Parameter samples: **Category** samples
     - Parameter from: **Device** device the samples come from (optional).
     Replaces each sample's device when set
     - Parameter workout: **Workout** workout
     - Parameter completion: block notifies about operation status
     */
    public func addCategory(
        _ samples: [Category],
        from device: Device?,
        to workout: Workout,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            let categorySamples = try samples.map {
                try $0.copyWith(device: device).asOriginal()
            }
            healthStore.add(
                categorySamples,
                to: try workout.asOriginal(),
                completion: completion
            )
        } catch {
            completion(false, error)
        }
    }
    /**
     Adds quantity samples to a saved workout
     - Parameter samples: **Quantity** samples
     - Parameter from: **Device** device the samples come from (optional).
     Replaces each sample's device when set
     - Parameter workout: **Workout** workout
     - Parameter completion: block notifies about operation status
     */
    public func addQuantity(
        _ samples: [Quantity],
        from device: Device?,
        to workout: Workout,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            let quantitySamples = try samples.map {
                try $0.copyWith(device: device).asOriginal()
            }
            healthStore.add(
                quantitySamples,
                to: try workout.asOriginal(),
                completion: completion
            )
        } catch {
            completion(false, error)
        }
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
     Deletes the previosly created sample.
     Supports **Quantity**, **Category**, **Workout**, **Correlation**, **Audiogram**, **VisionPrescription**,
     **StateOfMind**, **ScoredAssessment** and **CDADocument**;
     any other sample completes with HealthKitError.invalidType
     - Parameter sample: **Sample** sample
     - Parameter completion: block notifies about operation status
     */
    public func delete(
        sample: Sample,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            healthStore.delete(try original(of: sample), withCompletion: completion)
        } catch {
            completion(false, error)
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
     any other sample completes with HealthKitError.invalidType
     - Parameter sample: **Sample** sample
     - Parameter completion: block notifies about operation status
     */
    public func save(
        sample: Sample,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            healthStore.save(try original(of: sample), withCompletion: completion)
        } catch {
            completion(false, error)
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
