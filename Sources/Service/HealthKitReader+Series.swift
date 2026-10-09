//
//  HealthKitReader+Series.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

// MARK: - Series
extension HealthKitReader {
    /**
     Queries electrocardiogram.
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startDate, descending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter withVoltageMeasurements: the query will show the count of made measurements,
     and if set to **true** will provide ECG with voltage measurments array.
     By default with **false** the count of measurements will be still available,
     but the measurements array will be empty.
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func electrocardiogramQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        withVoltageMeasurements: Bool = false,
        resultsHandler: @escaping ElectrocardiogramResultsHandler
    ) throws -> QueryHandle {
        let retriever = ElectrocardiogramRetriever(healthStore: healthStore)
        return QueryHandle(try retriever.makeElectrocardiogramQuery(
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            withVoltageMeasurements: withVoltageMeasurements,
            resultsHandler: resultsHandler
        ))
    }
    /**
     Queries heartbeat series.
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startDate, descending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with every heartbeat series and its measurements,
     once all series are read
     - Throws: HealthKitError.invalidType
     */
    public func heartbeatSeriesQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping HeartbeatSeriesResultsDataHandler
    ) throws -> QueryHandle {
        return QueryHandle(try SeriesSampleRetriever().makeHeartbeatSeriesQuery(
            healthStore: healthStore,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            resultsHandler: resultsHandler
        ))
    }
    /**
     Queries workout route.
     - Requires: CLLocation permissions:
     “Privacy - Location Always and When In Use Usage Description”
     and “Privacy - Location When In Use Usage Description”.
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startDate, descending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with workout routes
     - Throws: HealthKitError.invalidType
     */
    public func workoutRouteQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping WorkoutRouteResultsDataHandler
    ) throws -> QueryHandle {
        return QueryHandle(try SeriesSampleRetriever().makeWorkoutRouteQuery(
            healthStore: healthStore,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            resultsHandler: resultsHandler
        ))
    }
    /**
     Queries the routes of one stored workout.
     The query looks the workout up by its uuid, then reads its routes with their locations.
     Stopping it before the workout is found stops both steps;
     once found, the routes are read to the end.
     - Requires: CLLocation permissions:
     “Privacy - Location Always and When In Use Usage Description”
     and “Privacy - Location When In Use Usage Description”.
     - Parameter workoutUUID: **String** uuid of the stored workout
     - Parameter limit: **Int** limit of the routes. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with the workout's routes, sorted by startDate, descending.
     HealthKitError.invalidIdentifier when no workout with that uuid is stored
     - Throws: HealthKitError.invalidValue on a malformed uuid
     */
    public func workoutRouteQuery(
        workoutUUID: String,
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping WorkoutRouteResultsDataHandler
    ) throws -> QueryHandle {
        let retriever = SeriesSampleRetriever()
        let routeQuery = { [healthStore] (workout: HKWorkout) in
            try retriever.makeWorkoutRouteQuery(
                healthStore: healthStore,
                predicate: HKQuery.predicateForObjects(from: workout),
                sortDescriptors: [
                    NSSortDescriptor(
                        key: HKSampleSortIdentifierStartDate,
                        ascending: false
                    )
                ],
                limit: limit,
                resultsHandler: resultsHandler
            )
        }
        return QueryHandle(try StoredSampleRetriever().makeStoredSamplesQuery(
            of: WorkoutType.workoutType,
            uuids: [workoutUUID]
        ) { [healthStore] samples, error in
            guard error == nil, let workout = samples.first as? HKWorkout else {
                resultsHandler(
                    [],
                    error ?? HealthKitError.invalidType("Samples \(samples) are not HKWorkout")
                )
                return
            }
            do {
                healthStore.execute(try routeQuery(workout))
            } catch {
                resultsHandler([], error)
            }
        })
    }
    /**
     Queries the individual quantities inside quantity series samples, e.g. step counts recorded as a series.
     - Parameter type: **QuantityType** type
     - Parameter unit: **String** unit compatible with the type
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter resultsHandler: returns a block with every quantity, ordered by sample start date
     - Throws: HealthKitError.invalidType, HealthKitError.invalidValue on a malformed or incompatible unit
     */
    public func quantitySeriesQuery(
        type: QuantityType,
        unit: String,
        predicate: NSPredicate? = .allSamples,
        resultsHandler: @escaping QuantitySeriesResultsHandler
    ) throws -> QueryHandle {
        guard let quantityType = type.hkObjectType as? HKQuantityType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKQuantityType")
        }
        let hkUnit = try quantityType.compatibleUnit(from: unit)
        var values = [QuantitySeriesValue]()
        let query = HKQuantitySeriesSampleQuery(
            quantityType: quantityType,
            predicate: predicate
        ) { (_, quantity, dateInterval, sample, done, error) in
            if let error = error {
                resultsHandler([], error)
                return
            }
            if let quantity = quantity, let dateInterval = dateInterval {
                values.append(
                    QuantitySeriesValue(
                        value: quantity.doubleValue(for: hkUnit),
                        unit: hkUnit.unitString,
                        startTimestamp: dateInterval.start.timeIntervalSince1970,
                        endTimestamp: dateInterval.end.timeIntervalSince1970,
                        sampleUUID: sample?.uuid.uuidString
                    )
                )
            }
            if done {
                resultsHandler(values, nil)
                values.removeAll()
            }
        }
        query.includeSample = true
        query.orderByQuantitySampleStartDate = true
        return QueryHandle(query)
    }
}
