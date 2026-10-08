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
