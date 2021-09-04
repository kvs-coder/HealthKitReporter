//
//  WorkoutEventTests.swift
//
//
//  Created by Kachalov, Victor on 04.09.21.
//

import XCTest
import HealthKitReporter

class WorkoutEventTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let startDate = Date(timeIntervalSince1970: 1626884)
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
        XCTAssertEqual(decoded.startTimestamp, 1626884)
        XCTAssertEqual(decoded.endTimestamp, 1626884)
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
        XCTAssertEqual(sut.startTimestamp, 1624906.675822, accuracy: epsilon)
        XCTAssertEqual(sut.endTimestamp, 1624906.675822, accuracy: epsilon)
        XCTAssertEqual(sut.duration, 0.0)
        XCTAssertEqual(sut.harmonized.value, 6)
        XCTAssertEqual(sut.harmonized.description, "Paused")
        XCTAssertEqual(sut.harmonized.metadata, ["event": "value"])
    }
}
