//
//  HealthKitLauncher.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public class HealthKitLauncher {
    /**
     - Parameters:
        - success: the status
        - error: error (optional)
    */
    public typealias StatusCompletionBlock = (_ success: Bool, _ error: Error?) -> Void

    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    /**
     Starts Watch App.
     - Parameter workoutConfiguration: **WorkoutConfiguration** workout configuration
     - Parameter completion: returns a block with samples
     */
    public func startWatchApp(
        with workoutConfiguration: WorkoutConfiguration,
        completion: @escaping StatusCompletionBlock
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
