//
//  SeriesSampleRetriever.swift
//  HealthKitReporter
//
//  Created by Victor on 24.11.20.
//

import HealthKit
import CoreLocation

class SeriesSampleRetriever {
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
        return HKSampleQuery(
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
            guard let samples = result as? [HKHeartbeatSeriesSample] else {
                resultsHandler(
                    [],
                    HealthKitError.invalidType("Samples \(result) are not HKHeartbeatSeriesSample")
                )
                return
            }
            let collector = SampleResultsCollector<HeartbeatSeries>(
                label: "HealthKitReporter.HeartbeatSeriesRetriever",
                count: samples.count
            )
            for (index, sample) in samples.enumerated() {
                collector.enter()
                healthStore.execute(
                    self.makeHeartbeatQuery(for: sample, at: index, collector: collector)
                )
            }
            collector.notify(resultsHandler)
        }
    }
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
        return HKSampleQuery(
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
            guard let samples = result as? [HKWorkoutRoute] else {
                resultsHandler(
                    [],
                    HealthKitError.invalidType("Samples \(result) are not HKWorkoutRoute")
                )
                return
            }
            let collector = SampleResultsCollector<WorkoutRoute>(
                label: "HealthKitReporter.WorkoutRouteRetriever",
                count: samples.count
            )
            for (index, sample) in samples.enumerated() {
                collector.enter()
                healthStore.execute(
                    self.makeRouteQuery(for: sample, at: index, collector: collector)
                )
            }
            collector.notify(resultsHandler)
        }
    }

    private func makeHeartbeatQuery(
        for sample: HKHeartbeatSeriesSample,
        at index: Int,
        collector: SampleResultsCollector<HeartbeatSeries>
    ) -> HKHeartbeatSeriesQuery {
        var measurements = [HeartbeatSeries.Measurement]()
        return HKHeartbeatSeriesQuery(
            heartbeatSeries: sample
        ) { (_, timeSinceSeriesStart, precededByGap, done, error) in
            if let error = error {
                collector.fail(index, with: error)
                return
            }
            measurements.append(
                HeartbeatSeries.Measurement(
                    timeSinceSeriesStart: timeSinceSeriesStart,
                    precededByGap: precededByGap,
                    done: done
                )
            )
            if done {
                collector.finish(
                    index,
                    with: HeartbeatSeries(sample: sample, measurements: measurements)
                )
            }
        }
    }
    private func makeRouteQuery(
        for sample: HKWorkoutRoute,
        at index: Int,
        collector: SampleResultsCollector<WorkoutRoute>
    ) -> HKWorkoutRouteQuery {
        var routes = [WorkoutRoute.Route]()
        return HKWorkoutRouteQuery(
            route: sample
        ) { (_, locations, done, error) in
            guard
                error == nil,
                let locations = locations
            else {
                collector.fail(
                    index,
                    with: error ?? HealthKitError.unknown("No locations for \(sample)")
                )
                return
            }
            routes.append(
                WorkoutRoute.Route(
                    locations: locations.map { WorkoutRoute.Location(location: $0) },
                    done: done
                )
            )
            if done {
                collector.finish(
                    index,
                    with: WorkoutRoute(sample: sample, routes: routes)
                )
            }
        }
    }
}
