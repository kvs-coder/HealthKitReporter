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
        healthKitReporter = try! HealthKitReporter()
    }
    override func tearDown() {
        healthKitReporter = nil
    }
    
    func testDateToISO() {
        let date = Date(timeIntervalSince1970: 1624906615)
        let formatted = date.formatted(with: Date.iso8601)
        XCTAssertEqual(formatted, "2021-06-28T20:56:55.000+02:00")
    }
}
