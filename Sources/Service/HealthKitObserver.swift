//
//  HealthKitObserver.swift
//  HealthKitReporter
//
//  Created by Victor on 23.09.20.
//

import HealthKit

/// **HealthKitObserver** class for HK observing operations
public class HealthKitObserver {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Sets observer query for type
     - Parameter type: **SampleType** type
     - Parameter predicate: **NSPredicate** predicate (optional). Nil by default
     - Parameter updateHandler: is called as soon any change happened in AppleHealth App
     */
    public func observerQuery(
        type: SampleType,
        predicate: NSPredicate? = nil,
        updateHandler: @escaping ObserverUpdateHandler
    ) throws -> ObserverQuery {
        guard let sampleType = type.original as? HKSampleType else {
            throw HealthKitError.invalidType("Invalid HKQuantityType: \(type)")
        }
        let query = HKObserverQuery(
            sampleType: sampleType,
            predicate: predicate
        ) { (query, completion, error) in
            guard error == nil else {
                updateHandler(query, nil, error)
                return
            }
            guard #available(iOS 9.3, *) else {
                updateHandler(query, nil, HealthKitError.notAvailable(
                    "Query objectType is not available for the current iOS"
                ))
                return
            }
            guard let id = query.objectType?.identifier else {
                updateHandler(
                    query,
                    nil,
                    HealthKitError.unknown("Unknown object type for query: \(query)")
                )
                return
            }
            updateHandler(query, id, nil)
            completion()
        }
        return query
    }
    /**
     Enables background notifications about changes in AppleHealth
     - Parameter type: **ObjectType** type
     - Parameter frequency: **HKUpdateFrequency** frequency. Hourly by default
     - Parameter completionHandler: is called as soon any change happened in AppleHealth App
     */
    public func enableBackgroundDelivery(
        type: ObjectType,
        frequency: UpdateFrequency = .hourly,
        completionHandler: @escaping StatusCompletionBlock
    ) {
        guard let objectType = type.original else {
            completionHandler(
                false,
                HealthKitError.invalidType("Unknown type: \(type)")
            )
            return
        }
        healthStore.enableBackgroundDelivery(
            for: objectType,
            frequency: frequency.original,
            withCompletion: completionHandler
        )
    }
    /**
     Disables All background notifications about changes in AppleHealth
     - Parameter completionHandler: is called as soon any change happened in AppleHealth App
     */
    public func disableAllBackgroundDelivery(
        completionHandler: @escaping StatusCompletionBlock
    ) {
        healthStore.disableAllBackgroundDelivery(completion: completionHandler)
    }
    /**
     Disables All background notifications about changes in AppleHealth
     - Parameter type: **ObjectType** type
     - Parameter completionHandler: is called as soon any change happened in AppleHealth App
     */
    public func disableBackgroundDelivery(
        type: ObjectType,
        completionHandler: @escaping StatusCompletionBlock
    ) {
        guard let objectType = type.original else {
            completionHandler(
                false,
                HealthKitError.invalidType("Unknown type: \(type)")
            )
            return
        }
        healthStore.disableBackgroundDelivery(
            for: objectType,
            withCompletion: completionHandler
        )
    }
}
