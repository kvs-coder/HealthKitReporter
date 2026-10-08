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
    ) throws -> QueryHandle {
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
    ) throws -> QueryHandle {
        guard let sampleType = type.hkObjectType as? HKSampleType else {
            throw HealthKitError.invalidType("Invalid HKSampleType: \(type)")
        }
        return QueryHandle(HKObserverQuery(
            sampleType: sampleType,
            predicate: predicate
        ) { (query, completion, error) in
            if let error = error {
                updateHandler(QueryHandle(query), nil, error, completion)
                return
            }
            guard let identifier = query.objectType?.identifier else {
                updateHandler(
                    QueryHandle(query),
                    nil,
                    HealthKitError.unknown("Unknown object type for query: \(query)"),
                    completion
                )
                return
            }
            updateHandler(QueryHandle(query), identifier, nil, completion)
        })
    }
    /**
     Sets one observer query for several types.
     - Parameter descriptors: **QueryDescriptor** types and predicates
     - Parameter updateHandler: is called with the identifiers of the types that changed.
     Call its **completion** once the update is processed, also on the error path
     - Throws: HealthKitError.invalidType
     */
    public func observerQuery(
        descriptors: [QueryDescriptor],
        updateHandler: @escaping ObserverDescriptorsUpdateHandler
    ) throws -> QueryHandle {
        return QueryHandle(HKObserverQuery(
            queryDescriptors: try descriptors.map { try $0.asOriginal() }
        ) { (query, sampleTypes, completion, error) in
            let identifiers = (sampleTypes ?? []).map(\.identifier).sorted()
            updateHandler(QueryHandle(query), identifiers, error, completion)
        })
    }
    /**
     Enables background notifications about changes in AppleHealth
     - Parameter type: **ObjectType** type
     - Parameter frequency: **UpdateFrequency** frequency. Hourly by default
     - Parameter completionHandler: is called as soon any change happened in AppleHealth App
     */
    public func enableBackgroundDelivery(
        type: ObjectType,
        frequency: UpdateFrequency = .hourly,
        completionHandler: @escaping StatusCompletionBlock
    ) {
        guard let objectType = type.hkObjectType else {
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
        guard let objectType = type.hkObjectType else {
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
