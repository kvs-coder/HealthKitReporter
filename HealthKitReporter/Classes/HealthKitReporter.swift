//
//  HealthKitReporter.swift
//  HealthKitReporter
//
//  Created by Victor on 23.09.20.
//
// <key>NSHealthShareUsageDescription</key>
// <string>This app needs permission to share your health data</string>
// <key>NSHealthUpdateUsageDescription</key>
// <string>This app needs permission to update your health data</string>

import Foundation
import HealthKit

/// **HealthKitReporter** class for HK easy integration
public class HealthKitReporter {
    /// **HealthKitReader** is reponsible for reading operations in HK
    public let reader: HealthKitReader
    /// **HealthKitWriter** is reponsible for writing operations in HK
    public let writer: HealthKitWriter
    /// **HealthKitObserver** is reponsible for observing in HK
    public let observer: HealthKitObserver
    /// **HealthKitLauncher** is reponsible for launching a WatchApp
    public let launcher: HealthKitLauncher
    /**
     Inits the instance of **HealthKitReporter** class.
     Every time when called, the new instance of **HKHealthStore** is created.
     - Requires: Apple Healt App is installed on the device.
     - Throws: `HealthKitError.notAvailable`
     - Returns: **HealthKitReporter** instance
     */
    public init() throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable()
        }
        let healthStore = HKHealthStore()
        self.reader = HealthKitReader(healthStore: healthStore)
        self.writer = HealthKitWriter(healthStore: healthStore)
        self.observer = HealthKitObserver(healthStore: healthStore)
        self.launcher = HealthKitLauncher(healthStore: healthStore)
    }
}
