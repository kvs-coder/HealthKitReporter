//
//  DemoViewModel.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import Foundation

/// Turns taps on demo rows into library calls and their results into row states
final class DemoViewModel {
    struct Input {
        /// A row the user tapped
        let run = PassthroughSubject<DemoRow, Never>()
        /// The app launched; on a fresh simulator this authorizes and seeds demo data
        let launched = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let sections = CurrentValueSubject<[DemoSection], Never>(DemoSection.allCases)
        let results = CurrentValueSubject<[DemoRow: DemoResult], Never>([:])
        /// Rows that finished, successfully or not, out of all rows
        let progress = CurrentValueSubject<(done: Int, total: Int), Never>((0, DemoRow.allCases.count))
    }

    let input = Input()
    let output = Output()

    private var cancellables = Set<AnyCancellable>()
    private let defaults: UserDefaults

    init(
        service: HealthKitReporterService = HealthKitReporterService(),
        defaults: UserDefaults = .standard
    ) {
        self.defaults = defaults
        input.run
            .filter { [unowned self] row in
                row.isLive || output.results.value[row] != .running
            }
            .handleEvents(receiveOutput: { [unowned self] row in
                output.results.value[row] = .running
            })
            .flatMap { row in
                service.publisher(for: row)
                    .map { DemoResult.success($0) }
                    .catch { Just(DemoResult.failure($0.localizedDescription)) }
                    .map { (row, $0) }
            }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] row, result in
                output.results.value[row] = result
            }
            .store(in: &cancellables)
        output.results
            .map { results in
                (results.values.filter { $0 != .running && $0 != .idle }.count, DemoRow.allCases.count)
            }
            .subscribe(output.progress)
            .store(in: &cancellables)
        bindFirstLaunch()
    }

    /// On a fresh simulator: authorize, then seed a week of data once
    private func bindFirstLaunch() {
        #if targetEnvironment(simulator)
        let seededKey = "HealthKitReporter_Example.seeded"
        input.launched
            .filter { [unowned self] in !defaults.bool(forKey: seededKey) }
            .sink { [unowned self] in
                input.run.send(.requestAuthorization)
            }
            .store(in: &cancellables)
        output.results
            .compactMap { $0[.requestAuthorization] }
            .filter { [unowned self] result in
                if case .success = result {
                    return !defaults.bool(forKey: seededKey)
                }
                return false
            }
            .first()
            .sink { [unowned self] _ in
                defaults.set(true, forKey: seededKey)
                input.run.send(.seed)
            }
            .store(in: &cancellables)
        #endif
    }
}
