//
//  HealthKitReporterTests.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 21.07.21.
//

import XCTest
import HealthKitReporter

class HealthKitReporterTests: XCTestCase {
    func testHealthDataIsAvailableOnTheSimulator() throws {
        XCTAssertTrue(HealthKitReporter.isHealthDataAvailable)
    }
    func testEachReporterHasItsOwnServices() throws {
        let sut = HealthKitReporter()
        let other = HealthKitReporter()
        XCTAssertFalse(sut.reader === other.reader)
        XCTAssertFalse(sut.writer === other.writer)
        XCTAssertFalse(sut.observer === other.observer)
        XCTAssertFalse(sut.manager === other.manager)
    }
}
