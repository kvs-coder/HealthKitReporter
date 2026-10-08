//
//  WorkoutTests.swift
//
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

class WorkoutTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let startDate = Date(timeIntervalSince1970: 1626884800)
        let endDate = startDate.addingTimeInterval(60)
        let sut = Workout(
            identifier: WorkoutType.workoutType.identifier!,
            startTimestamp: startDate.timeIntervalSince1970,
            endTimestamp: endDate.timeIntervalSince1970,
            device: Device(
                name: "Guy's iPhone",
                manufacturer: "Guy",
                model: "6.1.1",
                hardwareVersion: "some_0",
                firmwareVersion: "some_1",
                softwareVersion: "some_2",
                localIdentifier: "some_3",
                udiDeviceIdentifier: "some_4"
            ),
            sourceRevision: SourceRevision(
                source: Source(
                    name: "mySource",
                    bundleIdentifier: "com.kvs.hkreporter"
                ),
                version: "1.0.0",
                productType: "CocoaPod",
                systemVersion: "1.0.0.0",
                operatingSystem: SourceRevision.OperatingSystem(
                    majorVersion: 1,
                    minorVersion: 1,
                    patchVersion: 1
                )
            ),
            duration: 10.0,
            workoutEvents: [
                WorkoutEvent(
                    startTimestamp: startDate.timeIntervalSince1970,
                    endTimestamp: startDate.timeIntervalSince1970,
                    duration: 60.0,
                    harmonized: WorkoutEvent.Harmonized(
                        value: 6,
                        description: "Paused",
                        metadata: ["event": "value"]
                    )
                )
            ],
            harmonized: Workout.Harmonized(
                value: 6,
                description: "Badminton",
                totalEnergyBurned: 1.2,
                totalEnergyBurnedUnit: "kcal",
                totalDistance: 123,
                totalDistanceUnit: "m",
                totalSwimmingStrokeCount: 0,
                totalSwimmingStrokeCountUnit: "count",
                totalFlightsClimbed: 0,
                totalFlightsClimbedUnit: "count",
                metadata: ["harmonized": "value"]
            )
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            Workout.self,
            from: encoded.data(using: .utf8)!
        )
        XCTAssertEqual(decoded.identifier, "HKWorkoutTypeIdentifier")
        XCTAssertEqual(decoded.startTimestamp, 1626884800)
        XCTAssertEqual(decoded.endTimestamp, 1626884800 + 60)
        XCTAssertEqual(decoded.device?.name, "Guy's iPhone")
        XCTAssertEqual(decoded.device?.manufacturer, "Guy")
        XCTAssertEqual(decoded.device?.model, "6.1.1")
        XCTAssertEqual(decoded.device?.hardwareVersion, "some_0")
        XCTAssertEqual(decoded.device?.firmwareVersion, "some_1")
        XCTAssertEqual(decoded.device?.softwareVersion, "some_2")
        XCTAssertEqual(decoded.device?.localIdentifier, "some_3")
        XCTAssertEqual(decoded.device?.udiDeviceIdentifier, "some_4")
        XCTAssertEqual(decoded.sourceRevision.source.name, "mySource")
        XCTAssertEqual(decoded.sourceRevision.source.bundleIdentifier, "com.kvs.hkreporter")
        XCTAssertEqual(decoded.sourceRevision.version, "1.0.0")
        XCTAssertEqual(decoded.sourceRevision.productType, "CocoaPod")
        XCTAssertEqual(decoded.sourceRevision.systemVersion, "1.0.0.0")
        XCTAssertEqual(decoded.sourceRevision.operatingSystem.majorVersion, 1)
        XCTAssertEqual(decoded.sourceRevision.operatingSystem.minorVersion, 1)
        XCTAssertEqual(decoded.sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(decoded.duration, 10.0)
        XCTAssertEqual(decoded.workoutEvents[0].startTimestamp, 1626884800)
        XCTAssertEqual(decoded.workoutEvents[0].endTimestamp, 1626884800)
        XCTAssertEqual(decoded.workoutEvents[0].duration, 60.0)
        XCTAssertEqual(decoded.workoutEvents[0].harmonized.value, 6)
        XCTAssertEqual(decoded.workoutEvents[0].harmonized.description, "Paused")
        XCTAssertEqual(decoded.workoutEvents[0].harmonized.metadata, ["event": "value"])
        XCTAssertEqual(decoded.harmonized.value, 6)
        XCTAssertEqual(decoded.harmonized.totalEnergyBurned, 1.2)
        XCTAssertEqual(decoded.harmonized.totalEnergyBurnedUnit, "kcal")
        XCTAssertEqual(decoded.harmonized.totalDistance, 123)
        XCTAssertEqual(decoded.harmonized.totalDistanceUnit, "m")
        XCTAssertEqual(decoded.harmonized.totalSwimmingStrokeCount, 0)
        XCTAssertEqual(decoded.harmonized.totalSwimmingStrokeCountUnit, "count")
        XCTAssertEqual(decoded.harmonized.totalFlightsClimbed, 0)
        XCTAssertEqual(decoded.harmonized.totalFlightsClimbedUnit, "count")
        XCTAssertEqual(decoded.harmonized.metadata, ["harmonized": "value"])
    }
    func testCreateFromDictionary() throws {
        let dictionary: [String: Any] = [
            "identifier": "HKWorkoutTypeIdentifier",
            "startTimestamp": 1624906615.822,
            "endTimestamp": 1624906675.822,
            "device": [
                "name": "FlutterTracker",
                "manufacturer": "kvs",
                "model": "T-800",
                "hardwareVersion": "3",
                "firmwareVersion": "3.0",
                "softwareVersion": "1.1.1",
                "localIdentifier": "kvs.sample.app",
                "udiDeviceIdentifier": "444-888-555"
            ],
            "sourceRevision": [
                "source": [
                    "name": "health_kit_reporter_example",
                    "bundleIdentifier": "com.kvs.healthKitReporterExample"
                ],
                "version": "1",
                "productType": "iPhone13,3",
                "systemVersion": "14.5.0",
                "operatingSystem": [
                    "majorVersion": 14,
                    "minorVersion": 5,
                    "patchVersion": 0
                ]
            ],
            "duration": 60,
            "workoutEvents": [
                [
                    "type": "Paused",
                    "startTimestamp": 1624906675.822,
                    "endTimestamp": 1624906675.822,
                    "duration": 0,
                    "harmonized": [
                        "value": 6,
                        "description": "Paused",
                        "metadata": ["event": "value"]
                    ]
                ]
            ],
            "harmonized": [
                "value": 6,
                "description": "Basketball",
                "totalEnergyBurned": 1.2,
                "totalEnergyBurnedUnit": "Cal",
                "totalDistance": 123,
                "totalDistanceUnit": "m",
                "totalSwimmingStrokeCount": 2,
                "totalSwimmingStrokeCountUnit": "count",
                "totalFlightsClimbed": 1,
                "totalFlightsClimbedUnit": "count",
                "metadata": ["harmonized": "value"]
            ]
        ]
        let epsilon = 1.0
        let sut = try Workout.make(from: dictionary)
        XCTAssertEqual(sut.identifier, "HKWorkoutTypeIdentifier")
        XCTAssertEqual(sut.startTimestamp, 1624906615, accuracy: epsilon)
        XCTAssertEqual(sut.endTimestamp, 1624906675, accuracy: epsilon)
        XCTAssertEqual(sut.device?.name, "FlutterTracker")
        XCTAssertEqual(sut.device?.manufacturer, "kvs")
        XCTAssertEqual(sut.device?.model, "T-800")
        XCTAssertEqual(sut.device?.hardwareVersion, "3")
        XCTAssertEqual(sut.device?.firmwareVersion, "3.0")
        XCTAssertEqual(sut.device?.softwareVersion, "1.1.1")
        XCTAssertEqual(sut.device?.localIdentifier, "kvs.sample.app")
        XCTAssertEqual(sut.device?.udiDeviceIdentifier, "444-888-555")
        XCTAssertEqual(sut.sourceRevision.source.name, "health_kit_reporter_example")
        XCTAssertEqual(sut.sourceRevision.source.bundleIdentifier, "com.kvs.healthKitReporterExample")
        XCTAssertEqual(sut.sourceRevision.version, "1")
        XCTAssertEqual(sut.sourceRevision.productType, "iPhone13,3")
        XCTAssertEqual(sut.sourceRevision.systemVersion, "14.5.0")
        XCTAssertEqual(sut.sourceRevision.operatingSystem.majorVersion, 14)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.minorVersion, 5)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.patchVersion, 0)
        XCTAssertEqual(sut.duration, 60.0)
        XCTAssertEqual(sut.workoutEvents[0].startTimestamp, 1624906675, accuracy: epsilon)
        XCTAssertEqual(sut.workoutEvents[0].endTimestamp, 1624906675, accuracy: epsilon)
        XCTAssertEqual(sut.workoutEvents[0].duration, 0.0)
        XCTAssertEqual(sut.workoutEvents[0].harmonized.value, 6)
        XCTAssertEqual(sut.workoutEvents[0].harmonized.description, "Paused")
        XCTAssertEqual(sut.workoutEvents[0].harmonized.metadata, ["event": "value"])
        XCTAssertEqual(sut.harmonized.value, 6)
        XCTAssertEqual(sut.harmonized.description, "Basketball")
        XCTAssertEqual(sut.harmonized.totalEnergyBurned, 1.2)
        XCTAssertEqual(sut.harmonized.totalEnergyBurnedUnit, "Cal")
        XCTAssertEqual(sut.harmonized.totalDistance, 123)
        XCTAssertEqual(sut.harmonized.totalDistanceUnit, "m")
        XCTAssertEqual(sut.harmonized.totalSwimmingStrokeCount, 2)
        XCTAssertEqual(sut.harmonized.totalSwimmingStrokeCountUnit, "count")
        XCTAssertEqual(sut.harmonized.totalFlightsClimbed, 1)
        XCTAssertEqual(sut.harmonized.totalFlightsClimbedUnit, "count")
        XCTAssertEqual(sut.harmonized.metadata, ["harmonized": "value"])
    }
}
// MARK: - Payload
extension WorkoutTests {
    private var harmonizedDictionary: [String: Any] {
        return [
            "value": 37,
            "description": "Running",
            "totalEnergyBurned": 250.5,
            "totalEnergyBurnedUnit": "kcal",
            "totalDistance": 5000,
            "totalDistanceUnit": "m",
            "totalSwimmingStrokeCount": 0,
            "totalSwimmingStrokeCountUnit": "count",
            "totalFlightsClimbed": 3,
            "totalFlightsClimbedUnit": "count",
            "metadata": [
                "HKWasUserEntered": "1"
            ]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKWorkoutTypeIdentifier",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "duration": 60,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "workoutEvents": [
                [
                    "startTimestamp": startTimestamp,
                    "endTimestamp": endTimestamp,
                    "duration": 60,
                    "harmonized": [
                        "value": 1,
                        "description": "Pause"
                    ]
                ]
            ],
            "harmonized": harmonizedDictionary
        ]
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "duration", "sourceRevision", "harmonized"],
            in: dictionary,
            make: Workout.make
        )
        assertEachKeyIsRequired(
            [
                "value",
                "description",
                "totalEnergyBurnedUnit",
                "totalDistanceUnit",
                "totalSwimmingStrokeCountUnit",
                "totalFlightsClimbedUnit"
            ],
            in: harmonizedDictionary,
            make: Workout.Harmonized.make
        )
    }
    func testCreateFromDictionaryWithoutOptionalFields() throws {
        var harmonized = harmonizedDictionary
        let optionalKeys = [
            "totalEnergyBurned",
            "totalDistance",
            "totalSwimmingStrokeCount",
            "totalFlightsClimbed",
            "metadata"
        ]
        for key in optionalKeys {
            harmonized.removeValue(forKey: key)
        }
        var dictionary = dictionary
        dictionary.removeValue(forKey: "device")
        dictionary.removeValue(forKey: "workoutEvents")
        dictionary["harmonized"] = harmonized
        let sut = try Workout.make(from: dictionary)
        XCTAssertNil(sut.device)
        XCTAssertTrue(sut.workoutEvents.isEmpty)
        XCTAssertNil(sut.harmonized.totalEnergyBurned)
        XCTAssertNil(sut.harmonized.totalDistance)
        XCTAssertNil(sut.harmonized.totalSwimmingStrokeCount)
        XCTAssertNil(sut.harmonized.totalFlightsClimbed)
        XCTAssertNil(sut.harmonized.metadata)
    }
    func testCreateFromDictionaryWithInvalidWorkoutEventThrows() throws {
        var dictionary = dictionary
        dictionary["workoutEvents"] = [["duration": 60]]
        assertInvalidValue(try Workout.make(from: dictionary))
    }
    func testCopyWithNoArgumentsKeepsAllFields() throws {
        let sut = try Workout.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
    }
    func testCopyWithChangesOnlyGivenField() throws {
        let sut = try Workout.make(from: dictionary)
        let copy = sut.copyWith(duration: 120)
        XCTAssertEqual(copy.duration, 120, accuracy: 0.001)
        XCTAssertEqual(
            try json(copy, excluding: ["duration"]),
            try json(sut, excluding: ["duration"])
        )
        let harmonized = sut.harmonized.copyWith(totalDistance: 10)
        XCTAssertEqual(try XCTUnwrap(harmonized.totalDistance), 10, accuracy: 0.001)
        XCTAssertEqual(
            try json(harmonized, excluding: ["totalDistance"]),
            try json(sut.harmonized, excluding: ["totalDistance"])
        )
    }
}
