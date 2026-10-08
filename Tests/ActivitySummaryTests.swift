//
//  ActivitySummaryTests.swift
//  
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKit
import HealthKitReporter

class ActivitySummaryTests: XCTestCase {
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKActivitySummaryTypeIdentifier",
            "date": "2021-07-21T16:26:40.000Z",
            "harmonized": [
                "activeEnergyBurned": 450.5,
                "activeEnergyBurnedGoal": 500,
                "activeEnergyBurnedUnit": "kcal",
                "appleExerciseTime": 25,
                "appleExerciseTimeGoal": 30,
                "appleExerciseTimeUnit": "min",
                "appleStandHours": 10,
                "appleStandHoursGoal": 12,
                "appleStandHoursUnit": "count"
            ]
        ]
    }

    func testCreateFromDictionary() throws {
        let sut = try decode(ActivitySummary.self, from: dictionary)
        assertActivitySummary(sut)
    }
    func testCreateThenEncodeThenDecode() throws {
        let sut = try decode(ActivitySummary.self, from: dictionary)
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            ActivitySummary.self,
            from: try XCTUnwrap(encoded.data(using: .utf8))
        )
        assertActivitySummary(decoded)
    }
    func testCreateFromDictionaryWithoutDate() throws {
        var dictionary = dictionary
        dictionary.removeValue(forKey: "date")
        let sut = try decode(ActivitySummary.self, from: dictionary)
        XCTAssertNil(sut.date)
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "harmonized"],
            in: dictionary,
            decoding: ActivitySummary.self
        )
    }

    private func assertActivitySummary(
        _ sut: ActivitySummary,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.identifier, "HKActivitySummaryTypeIdentifier", file: file, line: line)
        XCTAssertEqual(sut.date, "2021-07-21T16:26:40.000Z", file: file, line: line)
        XCTAssertEqual(sut.harmonized.activeEnergyBurned, 450.5, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.activeEnergyBurnedGoal, 500, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.activeEnergyBurnedUnit, "kcal", file: file, line: line)
        XCTAssertEqual(sut.harmonized.appleExerciseTime, 25, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.appleExerciseTimeGoal, 30, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.appleExerciseTimeUnit, "min", file: file, line: line)
        XCTAssertEqual(sut.harmonized.appleStandHours, 10, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.appleStandHoursGoal, 12, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.appleStandHoursUnit, "count", file: file, line: line)
    }
}
// MARK: - Factory
extension ActivitySummaryTests {
}
