//
//  StatisticsTests.swift
//
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

class StatisticsTests: XCTestCase {
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKQuantityTypeIdentifierStepCount",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "harmonized": [
                "summary": 1200.5,
                "average": 600.25,
                "recent": 100,
                "min": 10,
                "max": 900,
                "unit": "count"
            ],
            "sources": [
                [
                    "name": "Health",
                    "bundleIdentifier": "com.apple.Health"
                ]
            ]
        ]
    }

    func testCreateFromDictionary() throws {
        let sut = try decode(Statistics.self, from: dictionary)
        assertStatistics(sut)
    }
    func testCreateThenEncodeThenDecode() throws {
        let sut = try decode(Statistics.self, from: dictionary)
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            Statistics.self,
            from: try XCTUnwrap(encoded.data(using: .utf8))
        )
        assertStatistics(decoded)
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "harmonized", "sources"],
            in: dictionary,
            decoding: Statistics.self
        )
    }
    func testCopyWithNoArgumentsKeepsAllFields() throws {
        let sut = try decode(Statistics.self, from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
    }
    func testCopyWithChangesOnlyGivenField() throws {
        let sut = try decode(Statistics.self, from: dictionary)
        let copy = sut.copyWith(identifier: "HKQuantityTypeIdentifierDistanceWalkingRunning")
        XCTAssertEqual(copy.identifier, "HKQuantityTypeIdentifierDistanceWalkingRunning")
        XCTAssertEqual(try json(copy, excluding: ["identifier"]), try json(sut, excluding: ["identifier"]))
        let harmonized = sut.harmonized.copyWith(summary: 1)
        XCTAssertEqual(try XCTUnwrap(harmonized.summary), 1, accuracy: 0.001)
        XCTAssertEqual(
            try json(harmonized, excluding: ["summary"]),
            try json(sut.harmonized, excluding: ["summary"])
        )
    }
    func testConvertedToSameUnitReturnsSelf() throws {
        let sut = try decode(Statistics.self, from: dictionary)
        XCTAssertEqual(try json(sut.converted(to: "count")), try json(sut))
    }
    func testConvertedToOtherUnitChangesUnitOnly() throws {
        let sut = try decode(Statistics.self, from: dictionary)
        let converted = try sut.converted(to: "km")
        XCTAssertEqual(converted.harmonized.unit, "km")
        XCTAssertEqual(
            try json(converted.harmonized, excluding: ["unit"]),
            try json(sut.harmonized, excluding: ["unit"])
        )
    }

    private func assertStatistics(
        _ sut: Statistics,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.identifier, "HKQuantityTypeIdentifierStepCount", file: file, line: line)
        XCTAssertEqual(sut.startTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.endTimestamp, 1626884860, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.summary ?? 0, 1200.5, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.average ?? 0, 600.25, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.recent ?? 0, 100, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.min ?? 0, 10, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.max ?? 0, 900, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.unit, "count", file: file, line: line)
        XCTAssertEqual(sut.sources.count, 1, file: file, line: line)
        XCTAssertEqual(sut.sources.first?.name, "Health", file: file, line: line)
        XCTAssertEqual(sut.sources.first?.bundleIdentifier, "com.apple.Health", file: file, line: line)
    }
}
