//
//  HealthKitReporterTests.swift
//  
//
//  Created by Kachalov, Victor on 21.07.21.
//

import XCTest
import HealthKitReporter

class HealthKitReporterTests: XCTestCase {
    var healthKitReporter: HealthKitReporter!

    override func setUp() {
        healthKitReporter = HealthKitReporter()
    }
    override func tearDown() {
        healthKitReporter = nil
    }
}
