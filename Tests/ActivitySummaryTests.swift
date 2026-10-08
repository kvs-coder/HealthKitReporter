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
    func testCreateFromActivitySummaryQueryResults() throws {
        let summary = HKActivitySummary()
        summary.activeEnergyBurned = HKQuantity(unit: .largeCalorie(), doubleValue: 450.5)
        summary.activeEnergyBurnedGoal = HKQuantity(unit: .largeCalorie(), doubleValue: 500)
        summary.appleExerciseTime = HKQuantity(unit: .minute(), doubleValue: 25)
        summary.appleExerciseTimeGoal = HKQuantity(unit: .minute(), doubleValue: 30)
        summary.appleStandHours = HKQuantity(unit: .count(), doubleValue: 10)
        summary.appleStandHoursGoal = HKQuantity(unit: .count(), doubleValue: 12)
        var summaries = [ActivitySummary]()
        let query = HealthKitReporter().reader.queryActivitySummary(monitorUpdates: true) { result, _ in
            summaries = result
        }
        let updateHandler = try XCTUnwrap(query.updateHandler)
        updateHandler(query, [summary], nil)
        let sut = try XCTUnwrap(summaries.first)
        XCTAssertEqual(summaries.count, 1)
        XCTAssertEqual(sut.identifier, "HKActivitySummaryTypeIdentifier")
        XCTAssertEqual(sut.harmonized.activeEnergyBurned, 450.5, accuracy: 0.001)
        XCTAssertEqual(sut.harmonized.activeEnergyBurnedGoal, 500, accuracy: 0.001)
        XCTAssertEqual(sut.harmonized.activeEnergyBurnedUnit, "Cal")
        XCTAssertEqual(sut.harmonized.appleExerciseTime, 25, accuracy: 0.001)
        XCTAssertEqual(sut.harmonized.appleExerciseTimeGoal, 30, accuracy: 0.001)
        XCTAssertEqual(sut.harmonized.appleExerciseTimeUnit, "min")
        XCTAssertEqual(sut.harmonized.appleStandHours, 10, accuracy: 0.001)
        XCTAssertEqual(sut.harmonized.appleStandHoursGoal, 12, accuracy: 0.001)
        XCTAssertEqual(sut.harmonized.appleStandHoursUnit, "count")
    }
    func testCreateMoveTimeSummaryWithCurrentGoals() throws {
        let summary = HKActivitySummary()
        summary.activityMoveMode = .appleMoveTime
        summary.appleMoveTime = HKQuantity(unit: .minute(), doubleValue: 40)
        summary.appleMoveTimeGoal = HKQuantity(unit: .minute(), doubleValue: 60)
        if #available(iOS 16.0, watchOS 9.0, *) {
            summary.exerciseTimeGoal = HKQuantity(unit: .minute(), doubleValue: 45)
            summary.standHoursGoal = HKQuantity(unit: .count(), doubleValue: 8)
        }
        if #available(iOS 18.0, watchOS 11.0, *) {
            summary.isPaused = true
        }
        var summaries = [ActivitySummary]()
        let query = HealthKitReporter().reader.queryActivitySummary(monitorUpdates: true) { result, _ in
            summaries = result
        }
        try XCTUnwrap(query.updateHandler)(query, [summary], nil)
        let sut = try XCTUnwrap(summaries.first).harmonized
        XCTAssertEqual(sut.activityMoveMode, "Apple move time")
        XCTAssertEqual(try XCTUnwrap(sut.appleMoveTime), 40, accuracy: 0.001)
        XCTAssertEqual(try XCTUnwrap(sut.appleMoveTimeGoal), 60, accuracy: 0.001)
        XCTAssertEqual(sut.appleMoveTimeUnit, "min")
        XCTAssertEqual(sut.appleExerciseTimeGoal, 45, accuracy: 0.001)
        XCTAssertEqual(sut.appleStandHoursGoal, 8, accuracy: 0.001)
        if #available(iOS 18.0, watchOS 11.0, *) {
            XCTAssertEqual(sut.paused, true)
        }
        let decoded = try JSONDecoder().decode(
            ActivitySummary.Harmonized.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        XCTAssertEqual(decoded.activityMoveMode, "Apple move time")
        XCTAssertEqual(decoded.appleMoveTimeUnit, "min")
    }
    func testActivitySummaryQueryError() throws {
        var summaries: [ActivitySummary]?
        var error: Error?
        let query = HealthKitReporter().reader.queryActivitySummary(
            monitorUpdates: true
        ) { result, resultError in
            summaries = result
            error = resultError
        }
        let updateHandler = try XCTUnwrap(query.updateHandler)
        updateHandler(query, nil, HealthKitError.unknown())
        XCTAssertEqual(summaries?.count, 0)
        XCTAssertNotNil(error)
    }
}
