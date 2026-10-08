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
     Sets observer query for type.
     HealthKit's completion handler is called right after **updateHandler** returns,
     so asynchronous work started there may be suspended in background delivery.
     Use the **ObserverCompletionUpdateHandler** variant to signal completion yourself.
     - Parameter type: **SampleType** type
     - Parameter predicate: **NSPredicate** predicate (optional). Nil by default
     - Parameter updateHandler: is called as soon any change happened in AppleHealth App
     - Throws: HealthKitError.invalidType
     */
    public func observerQuery(
        type: SampleType,
        predicate: NSPredicate? = nil,
        updateHandler: @escaping ObserverUpdateHandler
    ) throws -> ObserverQuery {
        return try observerQuery(
            type: type,
            predicate: predicate
        ) { (query, identifier, error, completion) in
            updateHandler(query, identifier, error)
            completion()
        }
    }
    /**
     Sets observer query for type, handing HealthKit's completion handler to the consumer.
     - Parameter type: **SampleType** type
     - Parameter predicate: **NSPredicate** predicate (optional). Nil by default
     - Parameter updateHandler: is called as soon any change happened in AppleHealth App.
     Call its **completion** once the update is processed, also on the error path
     - Throws: HealthKitError.invalidType
     */
    public func observerQuery(
        type: SampleType,
        predicate: NSPredicate? = nil,
        updateHandler: @escaping ObserverCompletionUpdateHandler
    ) throws -> ObserverQuery {
        guard let sampleType = type.original as? HKSampleType else {
            throw HealthKitError.invalidType("Invalid HKSampleType: \(type)")
        }
        return HKObserverQuery(
            sampleType: sampleType,
            predicate: predicate
        ) { (query, completion, error) in
            if let error = error {
                updateHandler(query, nil, error, completion)
                return
            }
            guard let identifier = query.objectType?.identifier else {
                updateHandler(
                    query,
                    nil,
                    HealthKitError.unknown("Unknown object type for query: \(query)"),
                    completion
                )
                return
            }
            updateHandler(query, identifier, nil, completion)
        }
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
