//
//  HealthKitReporter.swift
//  HealthKitReporter
//
//  Created by Florian on 23.09.20.
//

import Foundation
import HealthKit

public class HealthKitReporter {
    public let reader: HealthKitReader
    public let writer: HealthKitWriter
    public let observer: HealthKitObserver
    public let launcher: HealthKitLauncher

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
