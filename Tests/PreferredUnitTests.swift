//
//  PreferredUnitTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class PreferredUnitTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let sut = PreferredUnit(
            identifier: "HKQuantityTypeIdentifierStepCount",
            unit: "count"
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            PreferredUnit.self,
            from: try XCTUnwrap(encoded.data(using: .utf8))
        )
        XCTAssertEqual(decoded.identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(decoded.unit, "count")
    }
    func testCreateFromDictionary() throws {
        let sut = try PreferredUnit.make(
            from: [
                "identifier": "HKQuantityTypeIdentifierStepCount",
                "unit": "count"
            ]
        )
        XCTAssertEqual(sut.identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(sut.unit, "count")
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "unit"],
            in: [
                "identifier": "HKQuantityTypeIdentifierStepCount",
                "unit": "count"
            ],
            make: PreferredUnit.make
        )
    }
    func testCollectFromQuantityTypes() throws {
        let sut = PreferredUnit.collect(
            from: [
                QuantityType.stepCount: "count",
                QuantityType.distanceWalkingRunning: "km"
            ]
        ).sorted { $0.identifier < $1.identifier }
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[0].identifier, "HKQuantityTypeIdentifierDistanceWalkingRunning")
        XCTAssertEqual(sut[0].unit, "km")
        XCTAssertEqual(sut[1].identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(sut[1].unit, "count")
    }
}
