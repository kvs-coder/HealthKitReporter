//
//  WorkoutSession.swift
//  HealthKitReporterWatch
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import HealthKit
import HealthKitReporter

/// A live workout: HKWorkoutSession and HKLiveWorkoutBuilder, which the library leaves to apps.
/// Authorization and reading the saved workout go through HealthKitReporter
final class WorkoutSession: NSObject, ObservableObject {
    enum State: Equatable {
        case waiting
        case running(String)
        case ended(String)
        case failed(String)
    }

    @Published private(set) var state = State.waiting
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var heartRate: Double?

    private let reporter = HealthKitReporter()
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var timer: AnyCancellable?

    func start(_ configuration: HKWorkoutConfiguration) {
        let toWrite: [SampleType] = [WorkoutType.workoutType, QuantityType.activeEnergyBurned, QuantityType.heartRate]
        let toRead: [ObjectType] = toWrite + [QuantityType.distanceWalkingRunning]
        reporter.manager.requestAuthorization(toRead: toRead, toWrite: toWrite) { [weak self] success, error in
            DispatchQueue.main.async {
                guard success else {
                    self?.state = .failed(error?.localizedDescription ?? "Not authorized")
                    return
                }
                self?.begin(configuration)
            }
        }
    }

    func end() {
        session?.end()
    }

    private func begin(_ configuration: HKWorkoutConfiguration) {
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            session.delegate = self
            builder.delegate = self
            self.session = session
            self.builder = builder
            let start = Date()
            session.startActivity(with: start)
            builder.beginCollection(withStart: start) { [weak self] success, error in
                DispatchQueue.main.async {
                    guard success else {
                        self?.state = .failed(error?.localizedDescription ?? "Could not start")
                        return
                    }
                    self?.state = .running(configuration.activityType.name)
                    self?.startTimer()
                }
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsed = self?.builder?.elapsedTime ?? 0
            }
    }
    private func finish() {
        timer = nil
        builder?.endCollection(withEnd: Date()) { [weak self] _, _ in
            self?.builder?.finishWorkout { _, error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        self?.state = .failed(error?.localizedDescription ?? "Could not save")
                    }
                    return
                }
                self?.showSavedWorkout()
            }
        }
    }
    /// Reads the workout back through the library, as the iPhone's workoutQuery demo does
    private func showSavedWorkout() {
        let query = try? reporter.reader.workoutQuery(limit: 1) { [weak self] workouts, _ in
            let minutes = Int((workouts.first?.duration ?? 0) / 60)
            DispatchQueue.main.async {
                self?.state = .ended("Saved \(workouts.first?.harmonized.description ?? "workout"), \(minutes) min")
            }
        }
        query.map(reporter.manager.executeQuery)
    }
}
// MARK: - HKWorkoutSessionDelegate
extension WorkoutSession: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        if toState == .ended {
            finish()
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .failed(error.localizedDescription)
        }
    }
}
// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutSession: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        let heartRateType = HKQuantityType(.heartRate)
        guard collectedTypes.contains(heartRateType) else {
            return
        }
        let value = workoutBuilder.statistics(for: heartRateType)?
            .mostRecentQuantity()?
            .doubleValue(for: .count().unitDivided(by: .minute()))
        DispatchQueue.main.async { [weak self] in
            self?.heartRate = value
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}

private extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .running:
            return "Run"
        case .walking:
            return "Walk"
        case .cycling:
            return "Ride"
        default:
            return "Workout"
        }
    }
}
