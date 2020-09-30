//
//  HealthKitLauncher.swift
//  HealthKitReporter
//
//  Created by KVS on 25.09.20.
//

import Foundation
import HealthKit

public class HealthKitLauncher {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    public func startWatchApp(
        with workoutConfiguration: WorkoutConfiguration,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        do {
            healthStore.startWatchApp(
                with: try workoutConfiguration.asOriginal(),
                completion: completion
            )
        } catch {
            completion(false, error)
        }
    }
}
