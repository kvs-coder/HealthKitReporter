//
//  WorkoutActivityTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class WorkoutActivityTests: XCTestCase {
    private var dictionary: [String: Any] {
        return [
            "activityValue": Int(HKWorkoutActivityType.swimming.rawValue),
            "activityDescription": "Swimming",
            "locationValue": 1,
            "swimmingLocationValue": 1,
            "lapLength": 25,
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "metadata": ["HKWasUserEntered": true]
        ]
    }

    func testCreateFromDictionaryThenEncodeThenDecode() throws {
        let sut = try WorkoutActivity.make(from: dictionary)
        let decoded = try JSONDecoder().decode(
            WorkoutActivity.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        for activity in [sut, decoded] {
            XCTAssertEqual(activity.uuid, sut.uuid)
            XCTAssertEqual(activity.activityValue, Int(HKWorkoutActivityType.swimming.rawValue))
            XCTAssertEqual(activity.activityDescription, "Swimming")
            XCTAssertEqual(activity.locationValue, 1)
            XCTAssertEqual(activity.swimmingLocationValue, 1)
            XCTAssertEqual(try XCTUnwrap(activity.lapLength), 25, accuracy: 0.001)
            XCTAssertEqual(activity.startTimestamp, 1626884800, accuracy: 0.001)
            XCTAssertEqual(try XCTUnwrap(activity.endTimestamp), 1626884860, accuracy: 0.001)
            XCTAssertEqual(activity.duration, 60, accuracy: 0.001)
            XCTAssertTrue(activity.workoutEvents.isEmpty)
            XCTAssertTrue(activity.statistics.isEmpty)
            XCTAssertEqual(activity.metadata, ["HKWasUserEntered": true])
        }
        assertEachKeyIsRequired(
            [
                "activityValue", "activityDescription", "locationValue",
                "swimmingLocationValue", "startTimestamp"
            ],
            in: dictionary,
            make: WorkoutActivity.make
        )
    }
    func testCopyWith() throws {
        let sut = try WorkoutActivity.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith(), excluding: []), try json(sut))
        XCTAssertEqual(sut.copyWith().uuid, sut.uuid)
        let later = sut.copyWith(endTimestamp: sut.startTimestamp + 120)
        XCTAssertEqual(later.duration, 120, accuracy: 0.001)
        XCTAssertEqual(later.activityValue, sut.activityValue)
    }
}
