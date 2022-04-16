//
//  SeriesSampleRetriever.swift
//  HealthKitReporter
//
//  Created by Victor on 24.11.20.
//

import HealthKit
import CoreLocation

class SeriesSampleRetriever {
    @available(iOS 13.0, *)
    func makeHeartbeatSeriesQuery(
        healthStore: HKHealthStore,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        resultsHandler: @escaping HeartbeatSeriesResultsDataHandler
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
                resultsHandler([], error)
                return
            }
            var series = [HeartbeatSeries]()
            var seriesError: Error?
            let group = DispatchGroup()
            for element in result {
                guard let seriesSample = element as? HKHeartbeatSeriesSample else {
                    resultsHandler(
                        [],
                        HealthKitError.invalidType(
                            "Sample \(element) is not HKHeartbeatSeriesSample"
                        )
                    )
                    return
                }
                var measurements = [HeartbeatSeries.Measurement]()
                group.enter()
                let heartbeatSeriesQuery = HKHeartbeatSeriesQuery(
                    heartbeatSeries: seriesSample
                ) { (_, timeSinceSeriesStart, precededByGap, done, error) in
                    guard error == nil else {
                        seriesError = error
                        group.leave()
                        return
                    }
                    let measurement = HeartbeatSeries.Measurement(
                        timeSinceSeriesStart: timeSinceSeriesStart,
                        precededByGap: precededByGap,
                        done: done
                    )
                    measurements.append(measurement)
                    if done {
                        let sample = HeartbeatSeries(sample: seriesSample, measurements: measurements)
                        series.append(sample)
                        group.leave()
                    }
                }
                healthStore.execute(heartbeatSeriesQuery)
            }
            group.notify(queue: .global()) {
                resultsHandler(series, seriesError)
            }
        }
        return query
    }
    @available(iOS 11.0, *)
    func makeWorkoutRouteQuery(
        healthStore: HKHealthStore,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        resultsHandler: @escaping WorkoutRouteResultsDataHandler
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
                resultsHandler([], error)
                return
            }
            var workoutRoutes = [WorkoutRoute]()
            var workoutRoutesError: Error?
            let group = DispatchGroup()
            for element in result {
                guard let workoutRoute = element as? HKWorkoutRoute else {
                    resultsHandler(
                        [],
                        HealthKitError.invalidType(
                            "Sample \(element) is not HKWorkoutRoute"
                        )
                    )
                    return
                }
                var routes = [WorkoutRoute.Route]()
                group.enter()
                let workoutRouteQuery = HKWorkoutRouteQuery(
                    route: workoutRoute
                ) { (query, locations, done, error) in
                    guard
                        error == nil,
                        let locations = locations
                    else {
                        workoutRoutesError = error
                        group.leave()
                        return
                    }
                    let route = WorkoutRoute.Route(
                        locations: locations.map {
                            WorkoutRoute.Location(location: $0)
                        },
                        done: done
                    )
                    routes.append(route)
                    if done {
                        let workoutRoute = WorkoutRoute(sample: workoutRoute, routes: routes)
                        workoutRoutes.append(workoutRoute)
                        group.leave()
                    }
                }
                healthStore.execute(workoutRouteQuery)
            }
            group.notify(queue: .global()) {
                resultsHandler(workoutRoutes, workoutRoutesError)
            }
        }
        return query
    }
}
