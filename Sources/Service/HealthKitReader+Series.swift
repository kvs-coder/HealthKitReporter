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
     By default sorting by startData without ascending
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
        return QueryHandle(try ElectrocardiogramRetriever().makeElectrocardiogramQuery(
            healthStore: healthStore,
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
     By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with heartbeat series for each
     iteration until **done** of **HeartbeatSeries**  is True.
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
     By default sorting by startData without ascending
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
