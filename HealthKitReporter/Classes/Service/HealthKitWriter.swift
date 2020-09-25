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
            completion: completion)
    }
    public func addQuantitiy(
        _ samples: [Quantitiy],
        from: Device?,
        to workout: Workout,
        completion: @escaping (Bool, Error?) -> Void
    ) throws {
        let categorySamples = try samples.map { try $0.asOriginal() }
        healthStore.add(
            categorySamples,
            to: try workout.asOriginal(),
            completion: completion)
    }
}
