//
//  HealthKitWriter.swift
//  HealthKitReporter
//
//  Created by Florian on 24.09.20.
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
    ) throws {
        var setOfWriteTypes = Set<HKSampleType>()
        for type in toWrite {
            guard let objectType = type.rawValue as? HKSampleType else {
                throw HealthKitError.invalidType(
                    "Type \(type) has not HKObjectType representation"
                )
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
    ) throws {
        let categorySamples = try samples.map { try $0.asOriginal() }
        healthStore.add(
            categorySamples,
            to: try workout.asOriginal(),
            completion: completion
        )
    }
    public func addQuantitiy(
        _ samples: [Quantitiy],
        from: Device?,
        to workout: Workout,
        completion: @escaping (Bool, Error?) -> Void
    ) throws {
        let quantitySamples = try samples.map { try $0.asOriginal() }
        healthStore.add(
            quantitySamples,
            to: try workout.asOriginal(),
            completion: completion
        )
    }
    func delete(
        sample: Sample,
        completion: @escaping (Bool, Error?) -> Void
    ) throws {
        if let quantity = sample as? Quantitiy {
            healthStore.delete(try quantity.asOriginal(), withCompletion: completion)
        }
        if let category = sample as? Category {
            healthStore.delete(try category.asOriginal(), withCompletion: completion)
        }
        if let workout = sample as? Workout {
            healthStore.delete(try workout.asOriginal(), withCompletion: completion)
        }
    }
    public func deleteObjects(
        of objectType: HealthKitType,
        predicate: NSPredicate,
        completion: @escaping (Bool, Int, Error?) -> Void
    ) throws {
        guard let type = objectType.rawValue else {
            throw HealthKitError.invalidType("Object type was invalid: \(objectType)")
        }
        healthStore.deleteObjects(of: type, predicate: predicate, withCompletion: completion)
    }
    public func save(
        sample: Sample,
        completion: @escaping (Bool, Error?) -> Void
    ) throws {
        if let quantity = sample as? Quantitiy {
            healthStore.save(try quantity.asOriginal(), withCompletion: completion)
        }
        if let category = sample as? Category {
            healthStore.save(try category.asOriginal(), withCompletion: completion)
        }
        if let workout = sample as? Workout {
            healthStore.save(try workout.asOriginal(), withCompletion: completion)
        }
    }
}
