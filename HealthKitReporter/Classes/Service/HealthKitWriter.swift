//
//  HealthKitWriter.swift
//  HealthKitReporter
//
//  Created by Florian on 24.09.20.
//

import Foundation
import HealthKit

public class HealthKitWriter {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }


}
