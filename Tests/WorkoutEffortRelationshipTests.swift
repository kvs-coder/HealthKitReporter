//
//  WorkoutEffortRelationshipTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class WorkoutEffortRelationshipTests: XCTestCase {
    private var sut: WorkoutEffortRelationship {
        return WorkoutEffortRelationship(
            workout: Workout(
                uuid: storedUUID,
                identifier: "HKWorkoutTypeIdentifier",
                startTimestamp: startTimestamp,
                endTimestamp: endTimestamp,
                device: device,
                sourceRevision: sourceRevision,
                duration: 60,
                workoutEvents: [],
                harmonized: Workout.Harmonized(
                    value: Int(HKWorkoutActivityType.running.rawValue),
                    description: "Running",
                    totalEnergyBurned: nil,
                    totalEnergyBurnedUnit: "kcal",
                    totalDistance: nil,
                    totalDistanceUnit: "m",
                    totalSwimmingStrokeCount: nil,
                    totalSwimmingStrokeCountUnit: "count",
                    totalFlightsClimbed: nil,
                    totalFlightsClimbedUnit: "count",
                    metadata: nil
                )
            ),
            activityUUID: "C0FFEE00-0000-4000-8000-000000000001",
            samples: [
                Quantity(
                    identifier: "HKQuantityTypeIdentifierWorkoutEffortScore",
                    startTimestamp: startTimestamp,
                    endTimestamp: endTimestamp,
                    device: nil,
                    sourceRevision: sourceRevision,
                    harmonized: Quantity.Harmonized(value: 7, unit: "appleEffortScore", metadata: nil)
                )
            ]
        )
    }

    func testCreateThenEncodeThenDecode() throws {
        let sut = sut
        let decoded = try JSONDecoder().decode(
            WorkoutEffortRelationship.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        XCTAssertEqual(decoded.workout.uuid, storedUUID)
        XCTAssertEqual(decoded.workout.harmonized.description, "Running")
        XCTAssertEqual(decoded.activityUUID, "C0FFEE00-0000-4000-8000-000000000001")
        XCTAssertEqual(decoded.samples.count, 1)
        XCTAssertEqual(decoded.samples[0].uuid, sut.samples[0].uuid)
        XCTAssertEqual(decoded.samples[0].harmonized.value, 7, accuracy: 0.001)
        XCTAssertEqual(decoded.samples[0].harmonized.unit, "appleEffortScore")
    }
    func testCreateFromDictionary() throws {
        let sut = sut
        let data = try XCTUnwrap(sut.encoded().data(using: .utf8))
        let dictionary = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let made = try WorkoutEffortRelationship.make(from: dictionary)
        XCTAssertEqual(try json(made), try json(sut))
        XCTAssertEqual(made.samples[0].uuid, sut.samples[0].uuid)
        var withoutActivity = dictionary
        withoutActivity.removeValue(forKey: "activityUUID")
        XCTAssertNil(try WorkoutEffortRelationship.make(from: withoutActivity).activityUUID)
        assertEachKeyIsRequired(["workout", "samples"], in: dictionary, make: WorkoutEffortRelationship.make)
    }
}
