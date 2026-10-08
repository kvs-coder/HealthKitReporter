//
//  ReaderDemos.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import HealthKit
import HealthKitReporter

/// Characteristics and every read query
final class ReaderDemos: DemoPerformer {
    private let reporter: HealthKitReporter
    private let liveQueries: LiveQueries
    /// Anchor of the last anchored object query, so the next run only reports changes
    private var anchor: Anchor?

    init(reporter: HealthKitReporter, liveQueries: LiveQueries) {
        self.reporter = reporter
        self.liveQueries = liveQueries
    }

    func publisher(for row: DemoRow) -> AnyPublisher<String, Error> {
        if row == .anchoredObjectQueryDescriptors {
            return anchoredUpdates()
        }
        return reporter.publisher { [unowned self] completion in
            let reader = reporter.reader
            switch row {
            case .characteristics:
                completion(.success(reader.characteristics().json))
            case .quantityQuery:
                quantitiesOfEveryType(completion: completion)
            case .categoryQuery:
                reporter.countEveryType(reporter.demoCategoryTypes, completion: completion) { type, done in
                    try reader.categoryQuery(type: type, predicate: .lastWeek) { samples, _ in done(samples) }
                }
            case .sampleQuery:
                reporter.countEveryType(reporter.demoSampleTypes, completion: completion) { type, done in
                    try reader.sampleQuery(type: type, predicate: .lastWeek) { _, samples, _ in
                        done(samples)
                    }
                }
            case .sampleQueryDescriptors:
                try stepsAndSleepSamples(completion: completion)
            case .workoutQuery:
                let query = try reader.workoutQuery(predicate: .lastWeek) { workouts, error in
                    completion(error.map { .failure($0) } ?? .success(workouts.summary("workouts")))
                }
                reporter.manager.executeQuery(query)
            case .correlationSampleQuery:
                correlations(completion: completion)
            case .correlationQuery:
                try bloodPressure(completion: completion)
            case .anchoredObjectQuery:
                try anchoredSteps(completion: completion)
            case .sourceQuery:
                let query = try reader.sourceQuery(type: QuantityType.stepCount) { sources, error in
                    completion(error.map { .failure($0) } ?? .success(sources.summary("sources")))
                }
                reporter.manager.executeQuery(query)
            case .activitySummary:
                let query = reader.queryActivitySummary { summaries, error in
                    completion(
                        error.map { .failure($0) } ?? .success(summaries.summary("activity summaries"))
                    )
                }
                reporter.manager.executeQuery(query)
            default:
                throw HealthKitError.invalidOption("\(row) is not a read demo")
            }
        }
    }

    private var stepsAndSleep: [QueryDescriptor] {
        return [
            QueryDescriptor(type: QuantityType.stepCount, predicate: .lastWeek),
            QueryDescriptor(type: CategoryType.sleepAnalysis, predicate: .lastWeek)
        ]
    }

    /// Every quantity type, read in the user's preferred unit
    private func quantitiesOfEveryType(completion: @escaping DemoCompletion) {
        reporter.manager.preferredUnits(for: reporter.demoQuantityTypes) { [unowned self] units, error in
            guard error == nil else {
                completion(.failure(error ?? HealthKitError.unknown()))
                return
            }
            let unitByIdentifier = Dictionary(
                units.map { ($0.identifier, $0.unit) },
                uniquingKeysWith: { first, _ in first }
            )
            let types = reporter.demoQuantityTypes.filter { unitByIdentifier[$0.identifier ?? ""] != nil }
            reporter.countEveryType(types, completion: completion) { type, done in
                try reporter.reader.quantityQuery(
                    type: type,
                    unit: unitByIdentifier[type.identifier ?? ""] ?? "count",
                    predicate: .lastWeek
                ) { samples, _ in
                    done(samples)
                }
            }
        }
    }
    /// One sample query over steps and sleep
    private func stepsAndSleepSamples(completion: @escaping DemoCompletion) throws {
        let query = try reporter.reader.sampleQuery(descriptors: stepsAndSleep) { _, samples, error in
            completion(error.map { .failure($0) } ?? .success(samples.summary("steps and sleep samples")))
        }
        reporter.manager.executeQuery(query)
    }
    /// Blood pressure readings whose systolic value is from the last week
    private func bloodPressure(completion: @escaping DemoCompletion) throws {
        let query = try reporter.reader.correlationQuery(
            type: .bloodPressure,
            predicate: .lastWeek,
            typePredicates: ["HKQuantityTypeIdentifierBloodPressureSystolic": .lastWeek]
        ) { correlations, error in
            completion(
                error.map { .failure($0) } ?? .success(correlations.summary("blood pressure readings"))
            )
        }
        reporter.manager.executeQuery(query)
    }
    /// Steps since the stored anchor, which each run replaces
    private func anchoredSteps(completion: @escaping DemoCompletion) throws {
        let firstRun = anchor == nil
        let query = try reporter.reader.anchoredObjectQuery(
            type: QuantityType.stepCount,
            predicate: .lastWeek,
            anchor: anchor
        ) { [weak self] _, samples, deleted, anchor, error in
            self?.anchor = anchor
            let run = firstRun ? "First run" : "Since the stored anchor"
            let message = "\(run): \(samples.count) new, \(deleted.count) deleted. Tap again for changes"
            completion(error.map { .failure($0) } ?? .success(message))
        }
        reporter.manager.executeQuery(query)
    }
    private func correlations(completion: @escaping DemoCompletion) {
        let group = DispatchGroup()
        var lines = [String]()
        let lock = NSLock()
        for type in CorrelationType.allCases {
            group.enter()
            do {
                let query = try reporter.reader.correlationQuery(
                    type: type,
                    predicate: .lastWeek
                ) { samples, error in
                    lock.lock()
                    lines.append(
                        error.map { "\(type): \($0.localizedDescription)" }
                            ?? "\(type): \(samples.summary("samples"))"
                    )
                    lock.unlock()
                    group.leave()
                }
                reporter.manager.executeQuery(query)
            } catch {
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            completion(.success(lines.sorted().joined(separator: "\n")))
        }
    }
    /// Live: anchored query over steps and sleep that reports every change until stopped
    private func anchoredUpdates() -> AnyPublisher<String, Error> {
        liveQueries.publisher(for: .anchoredObjectQueryDescriptors) { [unowned self] subject in
            var updates = 0
            return try reporter.reader.anchoredObjectQuery(
                descriptors: stepsAndSleep,
                monitorUpdates: true
            ) { _, samples, deleted, _, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                updates += 1
                subject.send(
                    "Update \(updates): \(samples.count) samples, \(deleted.count) deleted. Live until Stop"
                )
            }
        }
    }
}

extension String {
    /// HKQuantityTypeIdentifierStepCount → StepCount
    var shortIdentifier: String {
        let prefixes = [
            "HKQuantityTypeIdentifier",
            "HKCategoryTypeIdentifier",
            "HKDataTypeIdentifier",
            "HKDataType"
        ]
        for prefix in prefixes where hasPrefix(prefix) {
            return String(dropFirst(prefix.count))
        }
        return self
    }
}
