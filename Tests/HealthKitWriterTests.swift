//
//  HealthKitWriterTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class HealthKitWriterTests: XCTestCase {
    /// **ObjectType** without an original **HKObjectType**
    private enum UnavailableType: ObjectType {
        case unavailable

        var original: HKObjectType? {
            return nil
        }
    }

    private var sut: HealthKitWriter!

    override func setUp() {
        super.setUp()
        sut = HealthKitReporter().writer
    }
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private var quantity: Quantity {
        return Quantity(
            identifier: "HKQuantityTypeIdentifierStepCount",
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: device,
            sourceRevision: sourceRevision,
            harmonized: Quantity.Harmonized(value: 100, unit: "count", metadata: ["you": "saved it"])
        )
    }
    private lazy var category = Category(
        identifier: "HKCategoryTypeIdentifierSleepAnalysis",
        startTimestamp: startTimestamp,
        endTimestamp: endTimestamp,
        device: device,
        sourceRevision: sourceRevision,
        harmonized: Category.Harmonized(
            value: 0,
            description: "HKCategoryValueSleepAnalysis",
            detail: "In Bed",
            metadata: ["you": "saved it"]
        )
    )
    private var workout: Workout {
        return Workout(
            identifier: "HKWorkoutTypeIdentifier",
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: device,
            sourceRevision: sourceRevision,
            duration: 60,
            workoutEvents: [
                WorkoutEvent(
                    startTimestamp: startTimestamp,
                    endTimestamp: startTimestamp,
                    duration: 0,
                    harmonized: WorkoutEvent.Harmonized(value: 1, description: "Pause", metadata: nil)
                )
            ],
            harmonized: Workout.Harmonized(
                value: Int(HKWorkoutActivityType.running.rawValue),
                description: "Running",
                totalEnergyBurned: 250,
                totalEnergyBurnedUnit: "kcal",
                totalDistance: 5000,
                totalDistanceUnit: "m",
                totalSwimmingStrokeCount: 0,
                totalSwimmingStrokeCountUnit: "count",
                totalFlightsClimbed: nil,
                totalFlightsClimbedUnit: "count",
                metadata: ["you": "saved it"]
            )
        )
    }
    private var correlation: Correlation {
        let systolic = quantity.copyWith(
            identifier: "HKQuantityTypeIdentifierBloodPressureSystolic",
            harmonized: Quantity.Harmonized(value: 123, unit: "mmHg", metadata: nil)
        )
        let diastolic = quantity.copyWith(
            identifier: "HKQuantityTypeIdentifierBloodPressureDiastolic",
            harmonized: Quantity.Harmonized(value: 83, unit: "mmHg", metadata: nil)
        )
        return Correlation(
            identifier: "HKCorrelationTypeIdentifierBloodPressure",
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: device,
            sourceRevision: sourceRevision,
            harmonized: Correlation.Harmonized(
                quantitySamples: [systolic, diastolic],
                categorySamples: [],
                metadata: ["you": "saved it"]
            )
        )
    }

    func testIsAuthorizedToWrite() throws {
        XCTAssertFalse(try sut.isAuthorizedToWrite(type: QuantityType.stepCount))
        assertInvalidType(try sut.isAuthorizedToWrite(type: UnavailableType.unavailable))
    }
    func testSaveConvertsEverySampleKindBeforeReachingHealthKit() throws {
        let samples: [Sample] = [quantity, category, workout, correlation]
        for sample in samples {
            let error = try waitForStatus { self.sut.save(sample: sample, completion: $0) }
            assertReachedHealthKit(error, "\(type(of: sample))")
        }
    }
    func testSaveWithInvalidIdentifier() throws {
        let samples: [Sample] = [
            quantity.copyWith(identifier: "invalid"),
            category.copyWith(identifier: "invalid"),
            correlation.copyWith(identifier: "invalid")
        ]
        for sample in samples {
            let error = try waitForStatus { self.sut.save(sample: sample, completion: $0) }
            assertInvalidType(try { throw try XCTUnwrap(error) }())
        }
    }
    func testDeleteConvertsEverySampleKindBeforeReachingHealthKit() throws {
        let samples: [Sample] = [quantity, category, workout]
        for sample in samples {
            let error = try waitForStatus { self.sut.delete(sample: sample, completion: $0) }
            assertReachedHealthKit(error, "\(type(of: sample))")
        }
    }
    func testDeleteWithInvalidIdentifier() throws {
        let error = try waitForStatus {
            self.sut.delete(sample: self.quantity.copyWith(identifier: "invalid"), completion: $0)
        }
        assertInvalidType(try { throw try XCTUnwrap(error) }())
    }
    func testAddSamplesToWorkout() throws {
        let quantityError = try waitForStatus {
            self.sut.addQuantitiy([self.quantity], from: nil, to: self.workout, completion: $0)
        }
        assertReachedHealthKit(quantityError, "addQuantitiy")
        let categoryError = try waitForStatus {
            self.sut.addCategory([self.category], from: nil, to: self.workout, completion: $0)
        }
        assertReachedHealthKit(categoryError, "addCategory")
        let invalidError = try waitForStatus {
            self.sut.addCategory(
                [self.category.copyWith(identifier: "invalid")],
                from: nil,
                to: self.workout,
                completion: $0
            )
        }
        assertInvalidType(try { throw try XCTUnwrap(invalidError) }())
    }
    func testDeleteObjectsWithInvalidType() throws {
        var status: (success: Bool, id: Int)?
        var deletionError: Error?
        sut.deleteObjects(of: UnavailableType.unavailable, predicate: .allSamples) { success, id, error in
            status = (success, id)
            deletionError = error
        }
        let deletion = try XCTUnwrap(status)
        XCTAssertFalse(deletion.success)
        XCTAssertEqual(deletion.id, -1)
        assertInvalidType(try { throw try XCTUnwrap(deletionError) }())
    }

    /// Calls the operation and waits for its **StatusCompletionBlock**, returning the reported error
    private func waitForStatus(
        _ operation: (@escaping StatusCompletionBlock) -> Void
    ) throws -> Error? {
        let expectation = expectation(description: "completion")
        var status: (success: Bool, error: Error?)?
        operation { success, error in
            status = (success, error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
        let result = try XCTUnwrap(status)
        XCTAssertFalse(result.success)
        return result.error
    }
    /// The payload converted to an HK object, so the error comes from HealthKit (no entitlement in tests)
    private func assertReachedHealthKit(
        _ error: Error?,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual((error as NSError?)?.domain, HKErrorDomain, message, file: file, line: line)
    }
}
