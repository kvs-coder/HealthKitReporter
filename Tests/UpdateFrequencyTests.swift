//
//  UpdateFrequencyTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

class UpdateFrequencyTests: XCTestCase {
    func testCreateFromInteger() throws {
        XCTAssertEqual(try UpdateFrequency.make(from: 1), .immediate)
        XCTAssertEqual(try UpdateFrequency.make(from: 2), .hourly)
        XCTAssertEqual(try UpdateFrequency.make(from: 3), .daily)
        XCTAssertEqual(try UpdateFrequency.make(from: 4), .weekly)
    }
    func testCreateFromRawValueRoundTrip() throws {
        for sut in [UpdateFrequency.immediate, .hourly, .daily, .weekly] {
            XCTAssertEqual(try UpdateFrequency.make(from: sut.rawValue), sut)
        }
    }
    func testCreateFromInvalidInteger() throws {
        assertInvalidValue(try UpdateFrequency.make(from: 0))
        assertInvalidValue(try UpdateFrequency.make(from: 5))
    }
}
