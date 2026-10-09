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
    func testDateComponentsFromDictionary() throws {
        let sut = DateComponents.make(from: ["year": 2021, "month": 7, "day": 21, "hour": 16, "minute": 26])
        XCTAssertEqual(sut.year, 2021)
        XCTAssertEqual(sut.month, 7)
        XCTAssertEqual(sut.day, 21)
        XCTAssertEqual(sut.hour, 16)
        XCTAssertEqual(sut.minute, 26)
        XCTAssertNil(sut.second)
        XCTAssertNil(sut.weekday)
        XCTAssertEqual(sut.calendar, Calendar.current)
        XCTAssertEqual(sut.timeZone, TimeZone.current)
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
    /// Fails without the POSIX locale on a device or simulator set to the 12-hour clock
    func testFixedFormatDatesUseTwentyFourHourDigits() throws {
        let utc = try XCTUnwrap(TimeZone(identifier: "UTC"))
        let sut = Date(timeIntervalSince1970: 1626884800)
        let string = sut.formatted(with: Date.iso8601, timezone: utc)
        XCTAssertEqual(string, "2021-07-21T16:26:40.000Z")
        XCTAssertEqual(string.asDate(format: Date.iso8601, timezone: utc), sut)
        XCTAssertEqual("2021-07-21T16:26:40.000Z".asDate(format: Date.iso8601, timezone: utc), sut)
    }
}
