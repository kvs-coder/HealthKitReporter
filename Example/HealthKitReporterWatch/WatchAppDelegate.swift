//
//  WatchAppDelegate.swift
//  HealthKitReporterWatch
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit
import WatchKit

/// Receives the workout configuration the iPhone sends and starts the session
final class WatchAppDelegate: NSObject, WKApplicationDelegate {
    let session = WorkoutSession()

    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        session.start(workoutConfiguration)
    }
}
