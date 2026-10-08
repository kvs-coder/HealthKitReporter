//
//  HealthKitManager.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

/// **HealthKitManager** class for HK managing operations
public class HealthKitManager {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Requests authorization for reading/writing Objects in HK.
     - Parameter toRead: an array of **ObjectType** types to read
     - Parameter toWrite: an array of **ObjectType** types to write
     - Parameter completion: returns a block with information about authorization window being displayed
     */
    public func requestAuthorization(
        toRead: [ObjectType],
        toWrite: [SampleType],
        completion: @escaping StatusCompletionBlock
    ) {
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
            guard let objectType = type.original as? HKQuantityType else {
                completion(
                    [],
                    HealthKitError.invalidType(
                        "Type \(type) has not HKQuantityType representation"
                    )
                )
                return
            }
            setOfTypes.insert(objectType)
        }
        healthStore.preferredUnits(for: setOfTypes) { (result, error) in
            guard error == nil else {
                completion([], error)
                return
            }
            let preferredUnits = PreferredUnit.collect(from: result)
            completion(preferredUnits, nil)
        }
    }
    /**
     Stops executing the query.
     - Parameter query: **Query**
     */
    public func stopQuery(_ query: Query) {
        healthStore.stop(query)
    }
    /**
     Executs query
     - Parameter query: **Query**
     */
    public func executeQuery(_ query: Query) {
        healthStore.execute(query)
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
    /**
     Asks the user which objects of a per-object authorization type (vision prescriptions) the app may read.
     - Parameter type: **SampleType** type, e.g. **VisionPrescriptionType.visionPrescription**
     - Parameter predicate: **NSPredicate** narrowing the objects offered (optional). nil by default
     - Parameter completion: block notifies about operation status
     */
    @available(iOS 16.0, *)
    public func requestPerObjectReadAuthorization(
        for type: SampleType,
        predicate: NSPredicate? = nil,
        completion: @escaping StatusCompletionBlock
    ) {
        guard let objectType = type.original else {
            completion(false, HealthKitError.invalidType("Type \(type) has not HKObjectType representation"))
            return
        }
        healthStore.requestPerObjectReadAuthorization(
            for: objectType,
            predicate: predicate,
            completion: completion
        )
    }
}
