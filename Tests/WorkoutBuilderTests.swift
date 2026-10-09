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
    /// Samples, events, metadata and activities all convert into builder steps; validation errors arrive
    /// synchronously, while the builder itself doesn't answer a test host without the HealthKit entitlement
    func testSaveWorkoutWithEverythingPassesValidation() throws {
        let heartRate = Quantity(
            identifier: "HKQuantityTypeIdentifierHeartRate",
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: nil,
            sourceRevision: sourceRevision,
            harmonized: Quantity.Harmonized(value: 120, unit: "count/min", metadata: nil)
        )
        let pause = WorkoutEvent(
            startTimestamp: startTimestamp,
            endTimestamp: startTimestamp,
            duration: 0,
            harmonized: WorkoutEvent.Harmonized(
                value: Int(HKWorkoutEventType.pause.rawValue),
                description: "Pause",
                metadata: nil
            )
        )
        var full = workout.copyWith(workoutEvents: [pause])
        if #available(iOS 16.0, watchOS 9.0, *) {
            full = full.copyWith(activities: [try WorkoutActivity.make(from: activityDictionary)])
        }
        let lock = NSLock()
        var reported: Error?
        HealthKitReporter().writer.saveWorkout(full, samples: [heartRate]) { _, error in
            lock.lock()
            reported = error
            lock.unlock()
        }
        lock.lock()
        defer { lock.unlock() }
        XCTAssertFalse(
            reported is HealthKitError,
            "Unexpected validation error: \(String(describing: reported))"
        )
    }
    func testSaveWorkoutWithInvalidActivity() throws {
        guard #available(iOS 16.0, watchOS 9.0, *) else {
            throw XCTSkip("Workout activities require iOS 16")
        }
        var unknownType = activityDictionary
        unknownType["activityValue"] = 99_999
        let unknown = workout.copyWith(activities: [try WorkoutActivity.make(from: unknownType)])
        assertInvalidType(try { throw try XCTUnwrap(try saveWithBuilder(unknown)) }())
        var endsEarly = activityDictionary
        endsEarly["endTimestamp"] = startTimestamp - 60
        let early = workout.copyWith(activities: [try WorkoutActivity.make(from: endsEarly)])
        assertInvalidValue(try { throw try XCTUnwrap(try saveWithBuilder(early)) }())
        let unknownLocations = [
            ("locationValue", 99),
            ("swimmingLocationValue", 99),
            ("swimmingLocationValue", 0)
        ]
        for (key, value) in unknownLocations {
            var unknownLocation = activityDictionary
            unknownLocation[key] = value
            let located = workout.copyWith(activities: [try WorkoutActivity.make(from: unknownLocation)])
            assertInvalidValue(try { throw try XCTUnwrap(try saveWithBuilder(located)) }())
        }
    }
    func testWorkoutEffort() throws {
        guard #available(iOS 18.0, watchOS 11.0, *) else {
            throw XCTSkip("Workout effort requires iOS 18")
        }
        let reader = HealthKitReporter().reader
        let query = try reader.workoutEffortRelationshipQuery(mostRelevant: true) { _, _, _ in }
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

    private func saveWithBuilder(_ workout: Workout, samples: [Quantity] = []) throws -> Error? {
        let expectation = expectation(description: "save")
        var result: (workout: Workout?, error: Error?)?
        HealthKitReporter().writer.saveWorkout(workout, samples: samples) { workout, error in
            result = (workout, error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
        XCTAssertNil(result?.workout)
        return result?.error
    }
}
