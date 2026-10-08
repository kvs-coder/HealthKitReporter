//
//  DemoPerformer.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import HealthKitReporter

/// Runs the demo rows of one area of the library
protocol DemoPerformer {
    func publisher(for row: DemoRow) -> AnyPublisher<String, Error>
}

typealias DemoCompletion = (Result<String, Error>) -> Void

extension HealthKitReporter {
    /// One result: wraps a callback based library call in a publisher
    func publisher(
        _ body: @escaping (@escaping DemoCompletion) throws -> Void
    ) -> AnyPublisher<String, Error> {
        return Deferred {
            Future { promise in
                do {
                    try body(promise)
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
