//
//  HealthKitObserver.swift
//  HealthKitReporter
//
//  Created by Victor on 23.09.20.
//

import Foundation
import HealthKit

public class HealthKitObserver {
    /**
     - Parameters:
        - success: the status
        - error: error (optional)
    */
    public typealias StatusCompletionBlock = (_ success: Bool, _ error: Error?) -> Void
    /**
     - Parameters:
        - success: the status
        - id: the deleted object id
        - error: error (optional)
    */
    public typealias ObserverUpdateHandler = (_ identifier: String?, _ error: Error?) -> Void

    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Sets observer query for type
     - Parameter type: **HealthKitType** type
     - Parameter predicate: **NSPredicate** predicate (optional). Nil by default
     - Parameter updateHandler: is called as soon any change happened in AppleHealth App
     */
    public func observerQuery(
        type: HealthKitType,
        predicate: NSPredicate? = nil,
        updateHandler: @escaping ObserverUpdateHandler
    ) {
        guard let sampleType = type.rawValue as? HKSampleType else {
            updateHandler(
                nil,
                HealthKitError.invalidType("Unknown type: \(type)")
            )
            return
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
    /**
     Enables background notifications about changes in AppleHealth
     - Parameter type: **HealthKitType** type
     - Parameter predicate: **NSPredicate** predicate (optional). Nil by default
     - Parameter completionHandler: is called as soon any change happened in AppleHealth App
     */
    public func enableBackgroundDelivery(
        type: HealthKitType,
        frequency: HKUpdateFrequency,
        completionHandler: @escaping StatusCompletionBlock
    ) {
        guard let objectType = type.rawValue else {
            completionHandler(
                false,
                HealthKitError.invalidType("Unknown type: \(type)")
            )
            return
        }
        healthStore.enableBackgroundDelivery(
            for: objectType,
            frequency: frequency,
            withCompletion: completionHandler
        )
    }
    /**
     Disable All background notifications about changes in AppleHealth
     - Parameter completionHandler: is called as soon any change happened in AppleHealth App
     */
    public func disableAllBackgroundDelivery(
        completionHandler: @escaping StatusCompletionBlock
    ) {
        healthStore.disableAllBackgroundDelivery(completion: completionHandler)
    }
    /**
     Disable All background notifications about changes in AppleHealth
     - Parameter type: **HealthKitType** type
     - Parameter completionHandler: is called as soon any change happened in AppleHealth App
     */
    public func disableBackgroundDelivery(
        type: HealthKitType,
        completionHandler: @escaping StatusCompletionBlock
    ) {
        guard let objectType = type.rawValue else {
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
