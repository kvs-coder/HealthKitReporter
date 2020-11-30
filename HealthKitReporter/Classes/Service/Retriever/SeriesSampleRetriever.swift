//
//  SeriesSampleRetriever.swift
//  HealthKitReporter
//
//  Created by Victor on 24.11.20.
//

import Foundation
import HealthKit
import CoreLocation

class SeriesSampleRetriever {
    @available(iOS 13.0, *)
    func makeHeartbeatSeriesQuery(
        healthStore: HKHealthStore,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        dataHandler: @escaping HeartbeatSeriesDataHandler
    ) throws -> HKSampleQuery {
        let heartbeatSeries = SeriesType.heartbeatSeries
        guard
            let seriesType = heartbeatSeries.original as? HKSeriesType
        else {
            throw HealthKitError.invalidType(
                "Invalid HKSeriesType: \(heartbeatSeries)"
            )
        }
        let query = HKSampleQuery(
            sampleType: seriesType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                dataHandler(nil, error)
                return
            }
            for element in result {
                guard let seriesSample = element as? HKHeartbeatSeriesSample else {
                    dataHandler(
                        nil,
                        HealthKitError.invalidType(
                            "Sample \(element) is not HKHeartbeatSeriesSample"
                        )
                    )
                    return
                }
                let heartbeatSeriesQuery = HKHeartbeatSeriesQuery(
                    heartbeatSeries: seriesSample
                ) { (query, timeSinceSeriesStart, precededByGap, done, error) in
                    guard error == nil else {
                        dataHandler(nil, error)
                        return
                    }
                    let heartbeatSerie = HeartbeatSerie(
                        timeSinceSeriesStart: timeSinceSeriesStart,
                        precededByGap: precededByGap,
                        done: done
                    )
                    dataHandler(heartbeatSerie, nil)
                }
                healthStore.execute(heartbeatSeriesQuery)
            }
        }
        return query
    }
    func makeWorkoutRouteQuery(
        healthStore: HKHealthStore,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        dataHandler: @escaping WorkoutRouteDataHandler
    ) throws -> HKSampleQuery {
        let workoutRoute = SeriesType.workoutRoute
        guard
            let seriesType = workoutRoute.original as? HKSeriesType
        else {
            throw HealthKitError.invalidType(
                "Invalid HKSeriesType: \(workoutRoute)"
            )
        }
        let query = HKSampleQuery(
            sampleType: seriesType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (query, data, error) in
            guard
                error == nil,
                let result = data
            else {
                dataHandler(nil, error)
                return
            }
            for element in result {
                guard let workoutRoute = element as? HKWorkoutRoute else {
                    dataHandler(
                        nil,
                        HealthKitError.invalidType(
                            "Sample \(element) is not HKHeartbeatSeriesSample"
                        )
                    )
                    return
                }
                let workoutRouteQuery = HKWorkoutRouteQuery(
                    route: workoutRoute
                ) { (query, locations, done, error) in
                    guard
                        error == nil,
                        let locations = locations
                    else {
                        dataHandler(nil, error)
                        return
                    }
                    let workoutRoute = WorkoutRoute(
                        locations: locations.map {
                            WorkoutRoute.Location(location: $0)
                        },
                        done: done
                    )
                    dataHandler(workoutRoute, nil)
                }
                healthStore.execute(workoutRouteQuery)
            }
        }
        return query
    }
}
