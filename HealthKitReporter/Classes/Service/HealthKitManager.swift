//
//  HealthKitManager.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public class HealthKitManager {
    /**
     - Parameters:
        - success: the status
        - error: error (optional)
    */
    public typealias StatusCompletionBlock = (_ success: Bool, _ error: Error?) -> Void
    /**
     - Parameters:
        - dictionary: dictionary of correponding type identifier (key) and unit (value)
        - error: error (optional)
    */
    public typealias PreferredUnitsCompeltion = (_ dictionary: [QuantityType: String], _ error: Error?) -> Void

    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Requests authorization for writing Objects in HK.
     - Parameter toRead: an array of **ObjectType** types to read
     - Parameter toWrite: an array of **ObjectType** types to write
     - Parameter completion: returns a block with information about authorization window being displayed
     */
    public func requestAuthorization<T>(
        toRead: [T],
        toWrite: [T],
        completion: @escaping StatusCompletionBlock
    ) where T: ObjectType {
        var setOfReadTypes = Set<HKObjectType>()
        for type in toRead {
            guard let objectType = type.original else {
                completion(
                    false,
                    HealthKitError.invalidType(
                        "Type \(type) has not HKObjectType representation"
                    )
                )
                return
            }
            setOfReadTypes.insert(objectType)
        }
        var setOfWriteTypes = Set<HKSampleType>()
        for type in toWrite {
            guard let objectType = type.original as? HKSampleType else {
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
            read: setOfReadTypes,
            completion: completion
        )
    }
    /**
     Queries preferred units.
     - Parameter quantityTypes: an array of **QuantityType** types
     - Parameter completion: returns a block with information preferred units
     */
    public func preferredUnits(
        for quantityTypes: [QuantityType],
        completion: @escaping PreferredUnitsCompeltion
    ) {
        var setOfTypes = Set<HKQuantityType>()
        for type in quantityTypes {
            guard let objectType = type.original else {
                completion(
                    [:],
                    HealthKitError.invalidType(
                        "Type \(type) has not HKQuantityType representation"
                    )
                )
                return
            }
            setOfTypes.insert(objectType)
        }
        healthStore.preferredUnits(for: setOfTypes) { (result, error) in
            var dictionary = [QuantityType: String]()
            for (key, value) in result {
                do {
                    let parsed = try key.parsed()
                    dictionary[parsed] = value.unitString
                } catch {
                    continue
                }
            }
            completion(dictionary, error)
        }
    }
    /**
     Starts Watch App.
     - Parameter workoutConfiguration: **WorkoutConfiguration** workout configuration
     - Parameter completion: returns a block with samples
     */
    public func startWatchApp(
        with workoutConfiguration: WorkoutConfiguration,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            healthStore.startWatchApp(
                with: try workoutConfiguration.asOriginal(),
                completion: completion
            )
        } catch {
            completion(false, error)
        }
    }
}
