//
//  HealthKitErrorTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

class HealthKitErrorTests: XCTestCase {
    func testLocalizedDescriptionIsTheMessage() throws {
        let errors: [HealthKitError] = [
            .notAvailable("a"), .unknown("b"), .invalidType("c"), .invalidIdentifier("d"),
            .invalidOption("e"), .invalidValue("f"), .parsingFailed("g"), .badEncoding("h"),
            .notImplementable("i")
        ]
        XCTAssertEqual(errors.map(\.localizedDescription), ["a", "b", "c", "d", "e", "f", "g", "h", "i"])
        let sut: Error = HealthKitError.invalidType()
        XCTAssertEqual(sut.localizedDescription, "Invalid type")
    }
}
