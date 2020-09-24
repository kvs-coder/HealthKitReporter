//
//  HealthKitObserver.swift
//  HealthKitReporter
//
//  Created by Florian on 23.09.20.
//

import Foundation
import HealthKit

public class HealthKitObserver {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    func observe(
        type: HealthKitType,
        predicate: NSPredicate? = nil,
        updateHandler: @escaping (String?, Error?) -> Void
    ) throws {
        guard let sampleType = type.rawValue as? HKSampleType else {
            throw HealthKitError.invalidType("Unknown type: \(type)")
        }
        let query = HKObserverQuery(
            sampleType: sampleType,
            predicate: predicate
        ) { (query, completion, error) in
            guard error == nil else {
                updateHandler(nil, error)
                return
            }
            guard let id = query.objectType?.identifier else {
                updateHandler(
                    nil,
                    HealthKitError.unknown("Unknown object type for query: \(query)")
                )
                return
            }
            updateHandler(id, nil)
            completion()
        }
        healthStore.execute(query)
    }

    func registerBackgroundUpdate(
        type: HealthKitType,
        frequency: HKUpdateFrequency,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) throws {
        guard let objectType = type.rawValue else {
            throw HealthKitError.invalidType("Unknown type: \(type)")
        }
        healthStore.enableBackgroundDelivery(
            for: objectType,
            frequency: frequency,
            withCompletion: completionHandler
        )
    }
}
