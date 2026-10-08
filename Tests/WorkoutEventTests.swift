//
//  WorkoutEventTests.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 04.09.21.
//

import XCTest
import HealthKit
import HealthKitReporter

class WorkoutEventTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let startDate = Date(timeIntervalSince1970: 1626884800)
        let sut = WorkoutEvent(
            startTimestamp: startDate.timeIntervalSince1970,
            endTimestamp: startDate.timeIntervalSince1970,
            duration: 60.0,
            harmonized: WorkoutEvent.Harmonized(
                value: 6,
                description: "Paused",
                metadata: ["event": "value"]
            )
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            WorkoutEvent.self,
            from: encoded.data(using: .utf8)!
        )
        XCTAssertEqual(decoded.startTimestamp, 1626884800)
        XCTAssertEqual(decoded.endTimestamp, 1626884800)
        XCTAssertEqual(decoded.duration, 60.0)
        XCTAssertEqual(decoded.harmonized.value, 6)
        XCTAssertEqual(decoded.harmonized.description, "Paused")
        XCTAssertEqual(decoded.harmonized.metadata, ["event": "value"])
    }
    func testCreateFromDictionary() throws {
        let dictionary: [String: Any] = [
            "startTimestamp": 1624906675.822,
            "endTimestamp": 1624906675.822,
            "duration": 0,
            "harmonized": [
                "value": 6,
                "description": "Paused",
                "metadata": ["event": "value"]
            ]
        ]
        let epsilon = 1.0
        let sut = try WorkoutEvent.make(from: dictionary)
        XCTAssertEqual(sut.startTimestamp, 1624906675.822, accuracy: epsilon)
        XCTAssertEqual(sut.endTimestamp, 1624906675.822, accuracy: epsilon)
        XCTAssertEqual(sut.duration, 0.0)
        XCTAssertEqual(sut.harmonized.value, 6)
        XCTAssertEqual(sut.harmonized.description, "Paused")
        XCTAssertEqual(sut.harmonized.metadata, ["event": "value"])
    }
    private var harmonizedDictionary: [String: Any] {
        return [
            "value": 1,
            "description": "Pause",
            "metadata": [
                "HKWasUserEntered": "1"
            ]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "duration": 60,
            "harmonized": harmonizedDictionary
        ]
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["startTimestamp", "endTimestamp", "duration", "harmonized"],
            in: dictionary,
            make: WorkoutEvent.make
        )
        assertEachKeyIsRequired(
            ["value", "description"],
            in: harmonizedDictionary,
            make: WorkoutEvent.Harmonized.make
        )
    }
    func testCopyWithNoArgumentsKeepsAllFields() throws {
        let sut = try WorkoutEvent.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
    }
    func testCopyWithChangesOnlyGivenField() throws {
        let sut = try WorkoutEvent.make(from: dictionary)
        let copy = sut.copyWith(duration: 30)
        XCTAssertEqual(copy.duration, 30, accuracy: 0.001)
        XCTAssertEqual(
            try json(copy, excluding: ["duration"]),
            try json(sut, excluding: ["duration"])
        )
        let harmonized = sut.harmonized.copyWith(value: 2)
        XCTAssertEqual(harmonized.value, 2)
        XCTAssertEqual(
            try json(harmonized, excluding: ["value"]),
            try json(sut.harmonized, excluding: ["value"])
        )
    }
}
// MARK: - Factory
extension WorkoutEventTests {
}
