//
//  StatisticsTests.swift
//  HealthKitReporter
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
                "unit": "count",
                "duration": 60
            ],
            "sourceStatistics": [
                [
                    "source": [
                        "name": "Health",
                        "bundleIdentifier": "com.apple.Health"
                    ],
                    "harmonized": [
                        "summary": 1200.5,
                        "unit": "count",
                        "duration": 60
                    ]
                ]
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
    func testMakeFromDictionary() throws {
        let sut = try Statistics.make(from: dictionary)
        assertStatistics(sut)
        XCTAssertEqual(try json(sut), try json(try decode(Statistics.self, from: dictionary)))
        XCTAssertEqual(try Statistics.collect(from: [dictionary]).count, 1)
        assertInvalidValue(try Statistics.collect(from: [dictionary, "invalid"]))
    }
    func testMakeFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "harmonized"],
            in: dictionary,
            make: Statistics.make
        )
        assertInvalidValue(try Statistics.Harmonized.make(from: ["summary": 1]))
        assertInvalidValue(try Statistics.SourceStatistics.make(from: ["source": [:]]))
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
    func testConvertedToOtherUnitConvertsEveryValue() throws {
        let sut = try decode(Statistics.self, from: dictionary).copyWith(
            identifier: "HKQuantityTypeIdentifierDistanceWalkingRunning",
            harmonized: Statistics.Harmonized(
                summary: 1000,
                average: 500,
                recent: nil,
                min: 10,
                max: 900,
                unit: "m",
                duration: 60
            ),
            sourceStatistics: [
                Statistics.SourceStatistics(
                    source: Source(name: "Health", bundleIdentifier: "com.apple.Health"),
                    harmonized: Statistics.Harmonized(
                        summary: 1000,
                        average: nil,
                        recent: nil,
                        min: nil,
                        max: nil,
                        unit: "m"
                    )
                )
            ]
        )
        let converted = try sut.converted(to: "km")
        XCTAssertEqual(converted.harmonized.unit, "km")
        XCTAssertEqual(try XCTUnwrap(converted.harmonized.duration), 60, accuracy: 0.000001)
        let sourceStatistics = try XCTUnwrap(converted.sourceStatistics?.first)
        XCTAssertEqual(sourceStatistics.harmonized.unit, "km")
        XCTAssertEqual(try XCTUnwrap(sourceStatistics.harmonized.summary), 1, accuracy: 0.000001)
        XCTAssertEqual(try XCTUnwrap(converted.harmonized.summary), 1, accuracy: 0.000001)
        XCTAssertEqual(try XCTUnwrap(converted.harmonized.average), 0.5, accuracy: 0.000001)
        XCTAssertNil(converted.harmonized.recent)
        XCTAssertEqual(try XCTUnwrap(converted.harmonized.min), 0.01, accuracy: 0.000001)
        XCTAssertEqual(try XCTUnwrap(converted.harmonized.max), 0.9, accuracy: 0.000001)
        XCTAssertEqual(
            try json(converted, excluding: ["harmonized", "sourceStatistics"]),
            try json(sut, excluding: ["harmonized", "sourceStatistics"])
        )
    }
    func testConvertedToMalformedOrIncompatibleUnitThrows() throws {
        let sut = try decode(Statistics.self, from: dictionary)
        assertInvalidValue(try sut.converted(to: "km"))
        assertInvalidValue(try sut.converted(to: "notAUnit"))
    }
    func testConvertedWithInvalidIdentifierThrows() throws {
        let sut = try decode(Statistics.self, from: dictionary).copyWith(identifier: "invalid")
        assertInvalidType(try sut.converted(to: "km"))
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
        XCTAssertEqual(sut.harmonized.duration ?? 0, 60, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.sourceStatistics?.count, 1, file: file, line: line)
        XCTAssertEqual(sut.sourceStatistics?.first?.source.name, "Health", file: file, line: line)
        XCTAssertEqual(
            sut.sourceStatistics?.first?.harmonized.summary ?? 0,
            1200.5,
            accuracy: 0.001,
            file: file,
            line: line
        )
        XCTAssertEqual(sut.sources.count, 1, file: file, line: line)
        XCTAssertEqual(sut.sources.first?.name, "Health", file: file, line: line)
        XCTAssertEqual(sut.sources.first?.bundleIdentifier, "com.apple.Health", file: file, line: line)
    }
}
