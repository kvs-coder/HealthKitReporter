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
    @available(iOS 14.0, *)
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
    ) throws -> SampleQuery {
        return try ElectrocardiogramRetriever().makeElectrocardiogramQuery(
            healthStore: healthStore,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            withVoltageMeasurements: withVoltageMeasurements,
            resultsHandler: resultsHandler
        )
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
    @available(iOS 13.0, *)
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
    ) throws -> SampleQuery {
        return try SeriesSampleRetriever().makeHeartbeatSeriesQuery(
            healthStore: healthStore,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            resultsHandler: resultsHandler
        )
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
    @available(iOS 11.0, *)
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
    ) throws -> SampleQuery {
        return try SeriesSampleRetriever().makeWorkoutRouteQuery(
            healthStore: healthStore,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            resultsHandler: resultsHandler
        )
    }
}
