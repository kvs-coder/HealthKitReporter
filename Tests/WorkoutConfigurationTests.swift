//
//  WorkoutConfigurationTests.swift
//  
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

class WorkoutConfigurationTests: XCTestCase {
    @available(iOS 10.0, *)
    func testCreateThenEncodeThenDecode() throws {
        let sut = WorkoutConfiguration(
            activityValue: 1,
            locationValue: 1,
            swimmingValue: 1,
            harmonized: WorkoutConfiguration.Harmonized(
                value: 10.0,
                unit: "m"
            )
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            WorkoutConfiguration.self,
            from: encoded.data(using: .utf8)!
        )
        XCTAssertEqual(decoded.activityValue, 1)
        XCTAssertEqual(decoded.locationValue, 1)
        XCTAssertEqual(decoded.swimmingValue, 1)
        XCTAssertEqual(decoded.harmonized.unit, "m")
        XCTAssertEqual(decoded.harmonized.value, 10.0)
        XCTAssertEqual(decoded.harmonized.unit, "m")
    }
    @available(iOS 10.0, *)
    func testCreateFromDictionary() throws {
        let dictionary: [String: Any] = [
            "activityValue": 1,
            "locationValue": 1,
            "swimmingValue": 1,
            "harmonized": [
                "value": 1.5,
                "unit": "m"
            ]
        ]
        let sut = try WorkoutConfiguration.make(from: dictionary)
        XCTAssertEqual(sut.activityValue, 1)
        XCTAssertEqual(sut.locationValue, 1)
        XCTAssertEqual(sut.swimmingValue, 1)
        XCTAssertEqual(sut.harmonized.value, 1.5)
        XCTAssertEqual(sut.harmonized.unit, "m")
    }
    #if os(iOS)
    func testStartWatchAppWithIncompatibleLapLengthUnit() throws {
        let sut = WorkoutConfiguration(
            activityValue: 46,
            locationValue: 1,
            swimmingValue: 1,
            harmonized: WorkoutConfiguration.Harmonized(value: 25, unit: "kg")
        )
        let expectation = expectation(description: "completion")
        var status: (success: Bool, error: Error?)?
        HealthKitReporter().manager.startWatchApp(with: sut) { success, error in
            status = (success, error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
        let result = try XCTUnwrap(status)
        XCTAssertFalse(result.success)
        assertInvalidValue(try { throw try XCTUnwrap(result.error) }())
    }
    func testStartWatchAppWithUnknownActivityType() throws {
        let sut = WorkoutConfiguration(
            activityValue: 99_999,
            locationValue: 1,
            swimmingValue: 1,
            harmonized: WorkoutConfiguration.Harmonized(value: 25, unit: "m")
        )
        var status: (success: Bool, error: Error?)?
        HealthKitReporter().manager.startWatchApp(with: sut) { success, error in
            status = (success, error)
        }
        XCTAssertEqual(status?.success, false)
        assertInvalidType(try { throw try XCTUnwrap(status?.error) }())
    }
    #endif
    func testCreateFromInvalidDictionary() throws {
        let harmonized: [String: Any] = ["value": 25, "unit": "m"]
        assertEachKeyIsRequired(
            ["activityValue", "locationValue", "swimmingValue", "harmonized"],
            in: [
                "activityValue": 46,
                "locationValue": 1,
                "swimmingValue": 1,
                "harmonized": harmonized
            ],
            make: WorkoutConfiguration.make
        )
        assertEachKeyIsRequired(
            ["value", "unit"],
            in: harmonized,
            make: WorkoutConfiguration.Harmonized.make
        )
    }
}
// MARK: - Copy
extension WorkoutConfigurationTests {
    func testCopyWithChangesOnlyGivenField() throws {
        let sut = WorkoutConfiguration(
            activityValue: 1,
            locationValue: 1,
            swimmingValue: 1,
            harmonized: WorkoutConfiguration.Harmonized(value: 10, unit: "m")
        )
        let copy = sut.copyWith(locationValue: 2, harmonized: sut.harmonized.copyWith(value: 25))
        XCTAssertEqual(copy.activityValue, 1)
        XCTAssertEqual(copy.locationValue, 2)
        XCTAssertEqual(copy.swimmingValue, 1)
        XCTAssertEqual(copy.harmonized.value, 25, accuracy: 0.001)
        XCTAssertEqual(copy.harmonized.unit, "m")
        XCTAssertEqual(
            try json(sut.copyWith()),
            try json(sut)
        )
    }
}
