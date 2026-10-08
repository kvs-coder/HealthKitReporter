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

        var identifier: String? {
            return nil
        }
    }
    /// **Sample** without an **HKSample** representation
    private struct UnsupportedSample: Sample {
        let uuid: String
        let identifier: String
        let startTimestamp: Double
        let endTimestamp: Double
    }

    private var sut: HealthKitWriter!

    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }
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
            let error = try waitForSave(sample)
            assertReachedHealthKit(error, "\(type(of: sample))")
        }
    }
    func testSaveWithInvalidIdentifier() throws {
        let samples: [Sample] = [
            quantity.copyWith(identifier: "invalid"),
            category.copyWith(identifier: "invalid"),
            correlation.copyWith(identifier: "invalid"),
            correlation.copyWith(
                harmonized: correlation.harmonized.copyWith(
                    quantitySamples: [quantity.copyWith(identifier: "invalid")]
                )
            )
        ]
        for sample in samples {
            let error = try waitForSave(sample)
            assertInvalidType(try { throw try XCTUnwrap(error) }())
        }
    }
    func testSaveAndDeleteUnsupportedSampleCallCompletion() throws {
        let sample = UnsupportedSample(
            uuid: UUID().uuidString,
            identifier: "invalid",
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp
        )
        let saveError = try waitForSave(sample)
        assertInvalidType(try { throw try XCTUnwrap(saveError) }())
        let deleteError = try waitForStatus { self.sut.delete(sample: sample, completion: $0) }
        assertInvalidType(try { throw try XCTUnwrap(deleteError) }())
    }
    func testSaveWithMalformedOrIncompatibleUnit() throws {
        let samples: [Sample] = [
            quantity.copyWith(harmonized: quantity.harmonized.copyWith(unit: "kg")),
            quantity.copyWith(harmonized: quantity.harmonized.copyWith(unit: "notAUnit")),
            workout.copyWith(harmonized: workout.harmonized.copyWith(totalEnergyBurnedUnit: "m")),
            workout.copyWith(harmonized: workout.harmonized.copyWith(totalDistanceUnit: "kg")),
            workout.copyWith(harmonized: workout.harmonized.copyWith(totalSwimmingStrokeCountUnit: "m")),
            correlation.copyWith(
                harmonized: Correlation.Harmonized(quantitySamples: [], categorySamples: [], metadata: nil)
            )
        ]
        for sample in samples {
            let error = try waitForSave(sample)
            assertInvalidValue(try { throw try XCTUnwrap(error) }())
        }
    }
    func testSaveWorkoutWithFlightsClimbed() throws {
        let harmonized = workout.harmonized
        let flightsWorkout = workout.copyWith(
            harmonized: Workout.Harmonized(
                value: harmonized.value,
                description: harmonized.description,
                totalEnergyBurned: harmonized.totalEnergyBurned,
                totalEnergyBurnedUnit: harmonized.totalEnergyBurnedUnit,
                totalDistance: harmonized.totalDistance,
                totalDistanceUnit: harmonized.totalDistanceUnit,
                totalSwimmingStrokeCount: nil,
                totalSwimmingStrokeCountUnit: harmonized.totalSwimmingStrokeCountUnit,
                totalFlightsClimbed: 3,
                totalFlightsClimbedUnit: "count",
                metadata: nil
            )
        )
        let error = try waitForSave(flightsWorkout)
        assertReachedHealthKit(error, "flights climbed")
        let invalidError = try waitForSave(
            flightsWorkout.copyWith(
                harmonized: flightsWorkout.harmonized.copyWith(totalFlightsClimbedUnit: "m")
            )
        )
        assertInvalidValue(try { throw try XCTUnwrap(invalidError) }())
    }
    func testDeleteConvertsEverySampleKindBeforeReachingHealthKit() throws {
        let samples: [Sample] = [quantity, category, workout]
        for sample in samples {
            let error = try waitForStatus { self.sut.delete(sample: sample, completion: $0) }
            assertReachedHealthKit(error, "\(type(of: sample))")
        }
    }
    func testDeleteWithInvalidIdentifier() throws {
        let samples: [Sample] = [
            quantity.copyWith(identifier: "invalid"),
            correlation.copyWith(identifier: "invalid")
        ]
        for sample in samples {
            let error = try waitForStatus { self.sut.delete(sample: sample, completion: $0) }
            assertInvalidType(try { throw try XCTUnwrap(error) }())
        }
    }
    func testDeleteWithMalformedUUID() throws {
        let sample = Quantity(
            uuid: "not-a-uuid",
            identifier: quantity.identifier,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: nil,
            sourceRevision: sourceRevision,
            harmonized: quantity.harmonized
        )
        let error = try waitForStatus { self.sut.delete(sample: sample, completion: $0) }
        assertInvalidValue(try { throw try XCTUnwrap(error) }())
    }
    func testAddSamplesToWorkout() throws {
        let quantityError = try waitForStatus {
            self.sut.addQuantity([self.quantity], from: nil, to: self.workout, completion: $0)
        }
        assertReachedHealthKit(quantityError, "addQuantity")
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

    /// Saves the sample, waits for its **SaveCompletionBlock** and returns the reported error
    private func waitForSave(_ sample: Sample) throws -> Error? {
        let expectation = expectation(description: "completion")
        var status: (success: Bool, error: Error?)?
        var savedUUID: String?
        sut.save(sample: sample) { success, uuid, error in
            status = (success, error)
            savedUUID = uuid
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
        let result = try XCTUnwrap(status)
        XCTAssertFalse(result.success)
        XCTAssertNil(savedUUID)
        return result.error
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
        wait(for: [expectation], timeout: 30)
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
// MARK: - Validation
extension HealthKitWriterTests {
    func testSaveCategoryOfEveryTypeWithUnknownValue() throws {
        for type in CategoryType.allCases {
            guard let identifier = type.identifier else {
                continue
            }
            let sample = category.copyWith(
                identifier: identifier,
                harmonized: category.harmonized.copyWith(value: 99)
            )
            let error = try waitForSave(sample)
            XCTAssertTrue(error is HealthKitError, "\(type)")
        }
    }
    func testSaveWithEndBeforeStartOrUnknownValue() throws {
        let event = WorkoutEvent(
            startTimestamp: startTimestamp,
            endTimestamp: startTimestamp,
            duration: 0,
            harmonized: WorkoutEvent.Harmonized(value: 99, description: "Unknown", metadata: nil)
        )
        let invalidValues: [Sample] = [
            quantity.copyWith(endTimestamp: startTimestamp - 60),
            category.copyWith(endTimestamp: startTimestamp - 60),
            workout.copyWith(endTimestamp: startTimestamp - 60),
            category.copyWith(harmonized: category.harmonized.copyWith(value: 99)),
            workout.copyWith(workoutEvents: [event.copyWith(endTimestamp: startTimestamp - 60)])
        ]
        for sample in invalidValues {
            assertInvalidValue(try { throw try XCTUnwrap(try waitForSave(sample)) }())
        }
        let strokesAndFlights = workout.copyWith(
            harmonized: workout.harmonized.copyWith(totalSwimmingStrokeCount: 10, totalFlightsClimbed: 3)
        )
        assertInvalidValue(try { throw try XCTUnwrap(try waitForSave(strokesAndFlights)) }())
        let unknownEvent = try waitForSave(workout.copyWith(workoutEvents: [event]))
        assertInvalidType(try { throw try XCTUnwrap(unknownEvent) }())
    }
}
// MARK: - Several samples
extension HealthKitWriterTests {
    func testSaveAndDeleteSeveralSamples() throws {
        let expectation = expectation(description: "save")
        var saved: (success: Bool, uuids: [String])?
        sut.save(samples: [quantity, category]) { success, uuids, error in
            saved = (success, uuids)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
        XCTAssertEqual(saved?.success, false)
        XCTAssertEqual(saved?.uuids, [])
        var invalid: Error?
        sut.save(samples: [quantity, category.copyWith(identifier: "invalid")]) { _, _, error in
            invalid = error
        }
        assertInvalidType(try { throw try XCTUnwrap(invalid) }())
        let deleteError = try waitForStatus {
            self.sut.delete(samples: [self.quantity, self.category], completion: $0)
        }
        assertReachedHealthKit(deleteError, "delete(samples:)")
        let invalidDelete = try waitForStatus {
            self.sut.delete(
                samples: [self.quantity, self.category.copyWith(identifier: "invalid")],
                completion: $0
            )
        }
        assertInvalidType(try { throw try XCTUnwrap(invalidDelete) }())
    }
    func testDeleteNoSamples() throws {
        let expectation = expectation(description: "delete")
        sut.delete(samples: []) { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
}
