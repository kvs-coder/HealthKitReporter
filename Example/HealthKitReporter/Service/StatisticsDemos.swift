//
//  StatisticsDemos.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import HealthKit
import HealthKitReporter

/// Statistics, statistics collections and series
final class StatisticsDemos: DemoPerformer {
    private let reporter: HealthKitReporter
    private let liveQueries: LiveQueries

    init(reporter: HealthKitReporter, liveQueries: LiveQueries) {
        self.reporter = reporter
        self.liveQueries = liveQueries
    }

    func publisher(for row: DemoRow) -> AnyPublisher<String, Error> {
        switch row {
        case .statisticsCollectionQuery:
            return dailySteps()
        case .statisticsCollectionBatches:
            return dailyHeartRate()
        default:
            break
        }
        return reporter.publisher { [unowned self] completion in
            let reader = reporter.reader
            switch row {
            case .statisticsQuery:
                statistics(completion: completion)
            case .electrocardiogramQuery:
                let query = try reader.electrocardiogramQuery(withVoltageMeasurements: true) { ecgs, error in
                    completion(
                        error.map { .failure($0) } ?? .success(ecgs.summary("ECGs (record one on a watch)"))
                    )
                }
                reporter.manager.executeQuery(query)
            case .heartbeatSeriesQuery:
                let query = try reader.heartbeatSeriesQuery { series, error in
                    completion(error.map { .failure($0) } ?? .success(series.summary("heartbeat series")))
                }
                reporter.manager.executeQuery(query)
            case .workoutRouteQuery:
                let query = try reader.workoutRouteQuery { routes, error in
                    completion(error.map { .failure($0) } ?? .success(routes.summary("workout routes")))
                }
                reporter.manager.executeQuery(query)
            case .quantitySeriesQuery:
                let query = try reader.quantitySeriesQuery(
                    type: .stepCount,
                    unit: "count",
                    predicate: .lastWeek
                ) { values, error in
                    completion(error.map { .failure($0) } ?? .success(values.summary("step series values")))
                }
                reporter.manager.executeQuery(query)
            default:
                throw HealthKitError.invalidOption("\(row) is not a statistics or series demo")
            }
        }
    }

    /// A quantity type read in **unit**, optionally split by source
    private struct StatisticsRequest {
        let type: QuantityType
        let unit: String
        let separateBySource: Bool
    }

    /// Cumulative steps and discrete heart rate this week, steps split by source
    private func statistics(completion: @escaping DemoCompletion) {
        let group = DispatchGroup()
        let lock = NSLock()
        var lines = [String]()
        let requests = [
            StatisticsRequest(type: .stepCount, unit: "count", separateBySource: true),
            StatisticsRequest(type: .heartRate, unit: "count/min", separateBySource: false)
        ]
        for request in requests {
            let type = request.type
            group.enter()
            do {
                let query = try reporter.reader.statisticsQuery(
                    type: type,
                    unit: request.unit,
                    predicate: .lastWeek,
                    separateBySource: request.separateBySource
                ) { statistics, error in
                    lock.lock()
                    lines.append(
                        error.map { "\(type): \($0.localizedDescription)" }
                            ?? "\(type): \(statistics?.json ?? "no data")"
                    )
                    lock.unlock()
                    group.leave()
                }
                reporter.manager.executeQuery(query)
            } catch {
                lines.append("\(type): \(error)")
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            completion(.success(lines.sorted().joined(separator: "\n")))
        }
    }
    /// Live: one callback per day, then again on every update
    private func dailySteps() -> AnyPublisher<String, Error> {
        liveQueries.publisher(for: .statisticsCollectionQuery) { [reporter] subject in
            let now = Date()
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
            var days = [String]()
            return try reporter.reader.statisticsCollectionQuery(
                type: .stepCount,
                unit: "count",
                anchorDate: Calendar.current.startOfDay(for: now),
                enumerateFrom: weekAgo,
                enumerateTo: now,
                intervalComponents: DateComponents(day: 1),
                monitorUpdates: true
            ) { statistics, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                guard let statistics = statistics else {
                    return
                }
                let day = Date(timeIntervalSince1970: statistics.startTimestamp)
                    .formatted(date: .abbreviated, time: .omitted)
                days.append("\(day): \(Int(statistics.harmonized.summary ?? 0)) steps")
                subject.send(days.suffix(7).joined(separator: "\n"))
            }
        }
    }
    /// Live: the whole week as one batch, then each changed day
    private func dailyHeartRate() -> AnyPublisher<String, Error> {
        liveQueries.publisher(for: .statisticsCollectionBatches) { [reporter] subject in
            let now = Date()
            return try reporter.reader.statisticsCollectionQuery(
                type: .heartRate,
                unit: "count/min",
                anchorDate: Calendar.current.startOfDay(for: now),
                enumerateFrom: Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now,
                intervalComponents: DateComponents(day: 1),
                monitorUpdates: true
            ) { (batch: [Statistics], error: Error?) in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                let lines = batch.map { statistics -> String in
                    let day = Date(timeIntervalSince1970: statistics.startTimestamp)
                        .formatted(date: .abbreviated, time: .omitted)
                    let min = Int(statistics.harmonized.min ?? 0)
                    let max = Int(statistics.harmonized.max ?? 0)
                    return "\(day): \(min)–\(max) bpm"
                }
                subject.send("Batch of \(batch.count) days\n" + lines.joined(separator: "\n"))
            }
        }
    }
}
