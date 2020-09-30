//
//  HealthKitWriter.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import Foundation
import HealthKit

public class HealthKitWriter {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    public func requestAuthorization(
        toWrite: [HealthKitType],
        completion: @escaping (Bool, Error?) -> Void
    ) {
        var setOfWriteTypes = Set<HKSampleType>()
        for type in toWrite {
            guard let objectType = type.rawValue as? HKSampleType else {
                completion(
                    false, HealthKitError.invalidType(
                        "Type \(type) has not HKObjectType representation"
                    )
                )
                return
            }
            setOfWriteTypes.insert(objectType)
        }
        healthStore.requestAuthorization(
            toShare: setOfWriteTypes,
            read: Set(),
            completion: completion
        )
    }
    public func addCategory(
        _ samples: [Category],
        from: Device?,
        to workout: Workout,
        completion: @escaping (Bool, Error?) -> Void
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
    public func addQuantitiy(
        _ samples: [Quantitiy],
        from: Device?,
        to workout: Workout,
        completion: @escaping (Bool, Error?) -> Void
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
    func delete(
        sample: Sample,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        do {
            if let quantity = sample as? Quantitiy {
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
    public func deleteObjects(
        of objectType: HealthKitType,
        predicate: NSPredicate,
        completion: @escaping (Bool, Int, Error?) -> Void
    ) {
        guard let type = objectType.rawValue else {
            completion(
                false,
                -1,
                HealthKitError.invalidType("Object type was invalid: \(objectType)")
            )
            return
        }
        healthStore.deleteObjects(of: type, predicate: predicate, withCompletion: completion)
    }
    public func save(
        sample: Sample,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        do {
            if let quantity = sample as? Quantitiy {
                healthStore.save(try quantity.asOriginal(), withCompletion: completion)
            }
            if let category = sample as? Category {
                healthStore.save(try category.asOriginal(), withCompletion: completion)
            }
            if let workout = sample as? Workout {
                healthStore.save(try workout.asOriginal(), withCompletion: completion)
            }
        } catch {
            completion(false, error)
        }
    }
}
