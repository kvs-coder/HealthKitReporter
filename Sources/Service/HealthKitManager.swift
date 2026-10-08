//
//  HealthKitManager.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

/// **HealthKitManager** class for HK managing operations
public class HealthKitManager {
    let healthStore: HKHealthStore

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
                    false,
                    HealthKitError.invalidType(
                        "Type \(type) has not HKSampleType representation"
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
     Tells whether requesting authorization for these types would show the permission sheet.
     - Parameter toRead: an array of **ObjectType** types to read
     - Parameter toWrite: an array of **SampleType** types to write
     - Parameter completion: returns a block with the request status
     */
    public func authorizationRequestStatus(
        toRead: [ObjectType],
        toWrite: [SampleType],
        completion: @escaping AuthorizationRequestStatusCompletion
    ) {
        let readTypes = toRead.compactMap(\.original)
        let writeTypes = toWrite.compactMap { $0.original as? HKSampleType }
        guard readTypes.count == toRead.count, writeTypes.count == toWrite.count else {
            completion(
                .unknown,
                HealthKitError.invalidType("Types \(toRead) \(toWrite) are not all available")
            )
            return
        }
        healthStore.getRequestStatusForAuthorization(
            toShare: Set(writeTypes),
            read: Set(readTypes)
        ) { status, error in
            completion(AuthorizationRequestStatus(requestStatus: status), error)
        }
    }
    /**
     The oldest date samples can be saved or queried for on this device.
     - Returns: **Date** earliest permitted sample date
     */
    public func earliestPermittedSampleDate() -> Date {
        return healthStore.earliestPermittedSampleDate()
    }
    /**
     Recalibrates the estimates HealthKit computes for a type, e.g. after a change in the user's health
     - Parameter type: **SampleType** type that allows recalibration, e.g. **QuantityType.vo2Max**
     - Parameter date: **Date** date from which to recalibrate
     - Parameter completion: block notifies about operation status
     */
    public func recalibrateEstimates(
        for type: SampleType,
        at date: Date,
        completion: @escaping StatusCompletionBlock
    ) {
        guard
            let sampleType = type.original as? HKSampleType,
            sampleType.allowsRecalibrationForEstimates
        else {
            completion(false, HealthKitError.invalidType("\(type) does not allow recalibrating estimates"))
            return
        }
        healthStore.recalibrateEstimates(sampleType: sampleType, date: date, completion: completion)
    }
    /**
     Queries preferred units.
     - Parameter quantityTypes: an array of **QuantityType** types
     - Parameter completion: returns a block with information preferred units
     */
    public func preferredUnits(
        for quantityTypes: [QuantityType],
        completion: @escaping PreferredUnitsCompletion
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
    #if os(iOS)
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
    #endif
    /**
     Asks the user which objects of a per-object authorization type (vision prescriptions, medications)
     the app may read.
     - Parameter type: **ObjectType** type, e.g. **VisionPrescriptionType.visionPrescription**
     or **MedicationType.userAnnotatedMedication**
     - Parameter predicate: **NSPredicate** narrowing the objects offered (optional). nil by default
     - Parameter completion: block notifies about operation status
     */
    @available(iOS 16.0, watchOS 9.0, *)
    public func requestPerObjectReadAuthorization(
        for type: ObjectType,
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
    #if os(iOS)
    /**
     Tells whether the device supports clinical health records.
     - Returns: true if clinical records can be read
     */
    public func supportsHealthRecords() -> Bool {
        return healthStore.supportsHealthRecords()
    }
    #endif
}
