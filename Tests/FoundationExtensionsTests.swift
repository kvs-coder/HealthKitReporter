//
//  FoundationExtensionsTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

class FoundationExtensionsTests: XCTestCase {
    func testMillisecondsToSeconds() throws {
        let sut: Double = 1626884800000
        XCTAssertEqual(sut.secondsSince1970, 1626884800, accuracy: 0.001)
        XCTAssertEqual(sut.secondsSince1970.asDate, Date(timeIntervalSince1970: 1626884800))
    }
    func testStringAsDateWithFormat() throws {
        let utc = try XCTUnwrap(TimeZone(identifier: "UTC"))
        let sut = "2021-07-21 16:26:40"
        XCTAssertEqual(
            sut.asDate(format: "yyyy-MM-dd HH:mm:ss", timezone: utc),
            Date(timeIntervalSince1970: 1626884800)
        )
        XCTAssertNil(sut.asDate(format: "dd.MM.yyyy", timezone: utc))
    }
}
