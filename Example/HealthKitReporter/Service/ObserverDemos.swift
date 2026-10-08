//
//  ObserverDemos.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import HealthKitReporter

/// Observer queries and background delivery
final class ObserverDemos: DemoPerformer {
    private let reporter: HealthKitReporter
    private let liveQueries: LiveQueries
    private let notifications = LocalNotificationManager()

    init(reporter: HealthKitReporter, liveQueries: LiveQueries) {
        self.reporter = reporter
        self.liveQueries = liveQueries
    }

    func publisher(for row: DemoRow) -> AnyPublisher<String, Error> {
        switch row {
        case .observerQuery:
            return observeSteps()
        case .observerQueryDescriptors:
            return observeStepsAndSleep()
        default:
            break
        }
        return reporter.publisher { [unowned self] completion in
            let observer = reporter.observer
            switch row {
            case .enableBackgroundDelivery:
                enableEveryFrequency([.immediate, .hourly, .daily, .weekly], lines: [], completion: completion)
            case .disableBackgroundDelivery:
                observer.disableBackgroundDelivery(type: QuantityType.stepCount) {
                    completion($0 ? .success("Step delivery disabled") : .failure($1 ?? HealthKitError.unknown()))
                }
            case .disableAllBackgroundDelivery:
                observer.disableAllBackgroundDelivery {
                    completion($0 ? .success("All delivery disabled") : .failure($1 ?? HealthKitError.unknown()))
                }
            default:
                throw HealthKitError.invalidOption("\(row) is not an observer demo")
            }
        }
    }

    /// Live: every change to steps, also posted as a local notification
    private func observeSteps() -> AnyPublisher<String, Error> {
        liveQueries.publisher(for: .observerQuery) { [unowned self] subject in
            var updates = 0
            return try reporter.observer.observerQuery(type: QuantityType.stepCount) { _, identifier, error, completion in
                defer { completion() }
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                updates += 1
                let text = "\(identifier?.shortIdentifier ?? "?") changed, update \(updates). Live until Stop"
                self.notifications.scheduleNotification(LocalNotification(title: "Observed", subtitle: text))
                subject.send(text)
            }
        }
    }
    /// Live: one observer for steps and sleep
    private func observeStepsAndSleep() -> AnyPublisher<String, Error> {
        liveQueries.publisher(for: .observerQueryDescriptors) { [reporter] subject in
            let descriptors = [
                QueryDescriptor(type: QuantityType.stepCount),
                QueryDescriptor(type: CategoryType.sleepAnalysis)
            ]
            return try reporter.observer.observerQuery(descriptors: descriptors) { _, identifiers, error, completion in
                defer { completion() }
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                let changed = identifiers.map(\.shortIdentifier).joined(separator: ", ")
                subject.send("Changed: \(changed.isEmpty ? "initial run" : changed). Live until Stop")
            }
        }
    }
    /// Enables step delivery at each frequency in turn, so each one is exercised
    private func enableEveryFrequency(
        _ frequencies: ArraySlice<UpdateFrequency>,
        lines: [String],
        completion: @escaping DemoCompletion
    ) {
        guard let frequency = frequencies.first else {
            completion(.success(lines.joined(separator: "\n")))
            return
        }
        reporter.observer.enableBackgroundDelivery(type: QuantityType.stepCount, frequency: frequency) { [unowned self] success, error in
            let line = "\(frequency): \(success ? "enabled" : error?.localizedDescription ?? "failed")"
            enableEveryFrequency(frequencies.dropFirst(), lines: lines + [line], completion: completion)
        }
    }
}
