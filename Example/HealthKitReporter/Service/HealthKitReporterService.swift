//
//  HealthKitReporterService.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 27.05.22.
//

import Combine
import HealthKitReporter

/// Runs a demo row through the library and publishes the outcome as text
final class HealthKitReporterService {
    private let performers: [DemoSection: DemoPerformer]

    init() {
        guard HealthKitReporter.isHealthDataAvailable else {
            performers = [:]
            return
        }
        let reporter = HealthKitReporter()
        let liveQueries = LiveQueries(reporter: reporter)
        let reader = ReaderDemos(reporter: reporter, liveQueries: liveQueries)
        let records = RecordsDemos(reporter: reporter)
        let writer = WriterDemos(reporter: reporter)
        let statistics = StatisticsDemos(reporter: reporter, liveQueries: liveQueries)
        performers = [
            .authorization: AuthorizationDemos(reporter: reporter),
            .characteristics: reader,
            .read: reader,
            .statistics: statistics,
            .series: statistics,
            .records: records,
            .wellbeing: records,
            .write: writer,
            .observe: ObserverDemos(reporter: reporter, liveQueries: liveQueries),
            .manager: ManagerDemos(reporter: reporter, liveQueries: liveQueries),
            .seeding: SeedingDemos(reporter: reporter)
        ]
    }

    func publisher(for row: DemoRow) -> AnyPublisher<String, Error> {
        guard let performer = performers[row.section] else {
            return Fail(error: HealthKitError.notAvailable("HealthKit is not available on this device"))
                .eraseToAnyPublisher()
        }
        return performer.publisher(for: row)
    }
}
