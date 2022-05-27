//
//  HealthKitWriter.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import HealthKit

/// **HealthKitWriter** class for HK writing operations
public class HealthKitWriter {
    private let healthStore: HKHealthStore

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
        guard let objectType = type.original else {
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
     Adds category samples from device to a workout
     - Parameter samples: **Category** samples
     - Parameter from: **Device** device (optional)
     - Parameter workout: **Workout** workout
     - Parameter completion: block notifies about operation status
     */
    public func addCategory(
        _ samples: [Category],
        from: Device?,
        to workout: Workout,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            let categorySamples = try samples.map { try $0.asOriginal() }
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
     Adds quantitiy samples from device to a workout
     - Parameter samples: **Quantitiy** samples
     - Parameter from: **Device** device (optional)
     - Parameter workout: **Workout** workout
     - Parameter completion: block notifies about operation status
     */
    public func addQuantitiy(
        _ samples: [Quantity],
        from: Device?,
        to workout: Workout,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            let quantitySamples = try samples.map { try $0.asOriginal() }
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
     Deletes the previosly created sample
     - Parameter sample: **Sample** sample
     - Parameter completion: block notifies about operation status
     */
    public func delete(
        sample: Sample,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            if let quantity = sample as? Quantity {
                healthStore.delete(try quantity.asOriginal(), withCompletion: completion)
            }
            if let category = sample as? Category {
                healthStore.delete(try category.asOriginal(), withCompletion: completion)
            }
            if let workout = sample as? Workout {
                healthStore.delete(try workout.asOriginal(), withCompletion: completion)
            }
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
        guard let type = objectType.original else {
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
     Saves the created sample
     - Parameter sample: **Sample** sample
     - Parameter completion: block notifies about operation status
     */
    public func save(
        sample: Sample,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            if let quantity = sample as? Quantity {
                healthStore.save(try quantity.asOriginal(), withCompletion: completion)
            }
            if let category = sample as? Category {
                healthStore.save(try category.asOriginal(), withCompletion: completion)
            }
            if let workout = sample as? Workout {
                healthStore.save(try workout.asOriginal(), withCompletion: completion)
            }
            if let correlation = sample as? Correlation {
                healthStore.save(try correlation.asOriginal(), withCompletion: completion)
            }
        } catch {
            completion(false, error)
        }
    }
}
