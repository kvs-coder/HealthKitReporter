//
//  SampleResultsCollector.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import Foundation

/// **SampleResultsCollector** gathers one result per sample from concurrent HealthKit callbacks.
/// Writes are serialized on a private queue; results keep the sample order
/// and the error of the first failed sample is reported.
final class SampleResultsCollector<Element> {
    private let queue: DispatchQueue
    private let group = DispatchGroup()
    private var results: [Element?]
    private var errors: [Error?]

    init(label: String, count: Int) {
        self.queue = DispatchQueue(label: label)
        self.results = Array(repeating: nil, count: count)
        self.errors = Array(repeating: nil, count: count)
    }

    func enter() {
        group.enter()
    }
    func finish(_ index: Int, with result: Element?) {
        queue.async {
            self.results[index] = result
            self.group.leave()
        }
    }
    func fail(_ index: Int, with error: Error) {
        queue.async {
            self.errors[index] = error
            self.group.leave()
        }
    }
    func notify(_ handler: @escaping ([Element], Error?) -> Void) {
        group.notify(queue: queue) {
            handler(
                self.results.compactMap { $0 },
                self.errors.compactMap { $0 }.first
            )
        }
    }
}
