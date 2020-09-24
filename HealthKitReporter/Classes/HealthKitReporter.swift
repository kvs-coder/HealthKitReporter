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
    public let observer: HealthKitObserver

    public init() throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable()
        }
        let healthStore = HKHealthStore()
        self.reader = HealthKitReader(healthStore: healthStore)
        self.observer = HealthKitObserver(healthStore: healthStore)
    }
}
