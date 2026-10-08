//
//  LiveQueries.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import Foundation
import HealthKitReporter

/// Long-lived queries that deliver updates until **stopAll**
final class LiveQueries {
    private let reporter: HealthKitReporter
    private let queue = DispatchQueue(label: "HealthKitReporter_Example.LiveQueries")
    private var queries = [DemoRow: Query]()

    init(reporter: HealthKitReporter) {
        self.reporter = reporter
    }

    /// Executes the query when subscribed, replacing a running one of the same row
    func publisher(
        for row: DemoRow,
        makeQuery: @escaping (PassthroughSubject<String, Error>) throws -> Query
    ) -> AnyPublisher<String, Error> {
        let subject = PassthroughSubject<String, Error>()
        return subject
            .handleEvents(receiveSubscription: { [weak self] _ in
                do {
                    let query = try makeQuery(subject)
                    self?.replace(row, with: query)
                } catch {
                    subject.send(completion: .failure(error))
                }
            })
            .eraseToAnyPublisher()
    }

    /// Stops every running query and tells how many there were
    func stopAll() -> Int {
        let running = queue.sync { () -> [Query] in
            defer { queries.removeAll() }
            return Array(queries.values)
        }
        running.forEach(reporter.manager.stopQuery)
        return running.count
    }

    private func replace(_ row: DemoRow, with query: Query) {
        let previous = queue.sync { () -> Query? in
            defer { queries[row] = query }
            return queries[row]
        }
        previous.map(reporter.manager.stopQuery)
        reporter.manager.executeQuery(query)
    }
}
