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
    public typealias PreferredUnitsCompeltion = (_ dictionary: [String: String], _ error: Error?) -> Void

    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Requests authorization for writing Objects in HK.
     - Parameter toRead: an array of **HealthKitType** types to read
     - Parameter toWrite: an array of **HealthKitType** types to write
     - Parameter completion: returns a block with information about authorization window being displayed
     */
    public func requestAuthorization(
        toRead: [HealthKitType],
        toWrite: [HealthKitType],
        completion: @escaping StatusCompletionBlock
    ) {
        var setOfReadTypes = Set<HKObjectType>()
        for type in toRead {
            guard let objectType = type.rawValue else {
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
            read: setOfReadTypes,
            completion: completion
        )
    }
    /**
     Queries preferred units.
     - Parameter quantityTypes: an array of **HealthKitType** types
     - Parameter completion: returns a block with information preferred units
     */
    public func preferredUnits(
        for quantityTypes: [HealthKitType],
        completion: @escaping PreferredUnitsCompeltion
    ) {
        var setOfTypes = Set<HKQuantityType>()
        for type in quantityTypes {
            guard let objectType = type.rawValue as? HKQuantityType else {
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
        healthStore.preferredUnits(for: setOfTypes) { (dictionary, error) in
            let mapped = dictionary.map { ($0.key.identifier, $0.value.unitString) }
            let dictionary = Dictionary(uniqueKeysWithValues: mapped)
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
