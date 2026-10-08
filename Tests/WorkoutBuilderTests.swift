//
//  WorkoutBuilderTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class WorkoutBuilderTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    private var activityDictionary: [String: Any] {
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
    private var workout: Workout {
        return Workout(
            identifier: "HKWorkoutTypeIdentifier",
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: device,
            sourceRevision: sourceRevision,
            duration: 60,
            workoutEvents: [],
            harmonized: Workout.Harmonized(
                value: Int(HKWorkoutActivityType.cycling.rawValue),
                description: "Cycling",
                totalEnergyBurned: 20,
                totalEnergyBurnedUnit: "kcal",
                totalDistance: 500,
                totalDistanceUnit: "m",
                totalSwimmingStrokeCount: nil,
                totalSwimmingStrokeCountUnit: "count",
                totalFlightsClimbed: nil,
                totalFlightsClimbedUnit: "count",
                metadata: ["HKWasUserEntered": true]
            )
        )
    }

    func testWorkoutActivityFromDictionaryThenEncodeThenDecode() throws {
        let sut = try WorkoutActivity.make(from: activityDictionary)
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
            in: activityDictionary,
            make: WorkoutActivity.make
        )
    }
    func testWorkoutWithActivitiesFromDictionary() throws {
        let sut = try JSONDecoder().decode(
            Workout.self,
            from: try XCTUnwrap(
                workout
                    .copyWith(activities: [try WorkoutActivity.make(from: activityDictionary)])
                    .encoded()
                    .data(using: .utf8)
            )
        )
        XCTAssertEqual(sut.activities?.map(\.activityDescription), ["Swimming"])
        XCTAssertNil(sut.statistics)
        XCTAssertNil(workout.activities)
    }
    func testSaveWorkoutWithInvalidInput() throws {
        for value in [99_999, -1] {
            let invalidType = workout.copyWith(harmonized: workout.harmonized.copyWith(value: value))
            assertInvalidType(try { throw try XCTUnwrap(try saveWithBuilder(invalidType)) }())
            assertInvalidType(try { throw try XCTUnwrap(try save(invalidType)) }())
        }
        let invalidUnit = workout.copyWith(harmonized: workout.harmonized.copyWith(totalDistanceUnit: "kg"))
        assertInvalidValue(try { throw try XCTUnwrap(try saveWithBuilder(invalidUnit)) }())
    }
    func testWorkoutEffort() throws {
        guard #available(iOS 18.0, watchOS 11.0, *) else {
            throw XCTSkip("Workout effort requires iOS 18")
        }
        let reader = HealthKitReporter().reader
        let query = reader.workoutEffortRelationshipQuery(mostRelevant: true) { _, _, _ in }
        XCTAssertNotNil(query)
        let effort = Quantity(
            identifier: "HKQuantityTypeIdentifierWorkoutEffortScore",
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: nil,
            sourceRevision: sourceRevision,
            harmonized: Quantity.Harmonized(value: 7, unit: "appleEffortScore", metadata: nil)
        )
        let steps = effort.copyWith(
            identifier: "HKQuantityTypeIdentifierStepCount",
            harmonized: Quantity.Harmonized(value: 7, unit: "count", metadata: nil)
        )
        let writer = HealthKitReporter().writer
        var notEffort: Error?
        writer.relateWorkoutEffort(steps, toWorkout: UUID().uuidString) { _, error in
            notEffort = error
        }
        assertInvalidType(try { throw try XCTUnwrap(notEffort) }())
        let relate = expectation(description: "relate")
        writer.relateWorkoutEffort(effort, toWorkout: UUID().uuidString) { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            relate.fulfill()
        }
        let unrelate = expectation(description: "unrelate")
        writer.unrelateWorkoutEffort(effort, fromWorkout: UUID().uuidString) { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            unrelate.fulfill()
        }
        wait(for: [relate, unrelate], timeout: 30)
    }

    private func saveWithBuilder(_ workout: Workout) throws -> Error? {
        let expectation = expectation(description: "save")
        var result: (workout: Workout?, error: Error?)?
        HealthKitReporter().writer.saveWorkout(workout) { workout, error in
            result = (workout, error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
        XCTAssertNil(result?.workout)
        return result?.error
    }
}
