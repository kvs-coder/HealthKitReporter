//
//  StoreOperationsTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

/// Manager, observer and writer operations complete on every path.
/// The test host has no HealthKit entitlement, so valid requests end in HealthKit errors
class StoreOperationsTests: XCTestCase {
    /// **SampleType** the library can't turn into a HealthKit type
    private enum UnavailableType: SampleType {
        case unavailable

        var identifier: String? {
            return nil
        }
    }

    private let reporter = HealthKitReporter()

    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    func testCharacteristicsWithoutAuthorizationAreEmpty() throws {
        let sut = reporter.reader.characteristics()
        XCTAssertNil(sut.biologicalSex)
        XCTAssertNil(sut.birthday)
        XCTAssertNil(sut.bloodType)
        XCTAssertNil(sut.fitzpatrickSkinType)
        XCTAssertNil(sut.wheelchairUse)
        XCTAssertNil(sut.activityMoveMode)
    }
    func testRequestAuthorization() throws {
        let manager = reporter.manager
        assertFails(invalidType: true) {
            manager.requestAuthorization(toRead: [UnavailableType.unavailable], toWrite: [], completion: $0)
        }
        assertFails(invalidType: true) {
            manager.requestAuthorization(toRead: [], toWrite: [UnavailableType.unavailable], completion: $0)
        }
        assertFails {
            manager.requestAuthorization(
                toRead: [QuantityType.stepCount],
                toWrite: [QuantityType.stepCount],
                completion: $0
            )
        }
        assertFails {
            manager.requestAuthorization(
                toRead: [SeriesType.heartbeatSeries, SeriesType.workoutRoute, DocumentType.cda],
                toWrite: [SeriesType.heartbeatSeries, SeriesType.workoutRoute],
                completion: $0
            )
        }
        assertFails(invalidType: true) {
            manager.requestAuthorization(toRead: [CorrelationType.bloodPressure], toWrite: [], completion: $0)
        }
        assertFails(invalidType: true) {
            manager.requestAuthorization(toRead: [], toWrite: [CorrelationType.bloodPressure], completion: $0)
        }
        assertFails(invalidType: true) {
            manager.requestAuthorization(
                toRead: [],
                toWrite: [QuantityType.appleExerciseTime],
                completion: $0
            )
        }
        if #available(iOS 16.0, watchOS 9.0, *) {
            assertFails(invalidType: true) {
                manager.requestAuthorization(
                    toRead: [VisionPrescriptionType.visionPrescription],
                    toWrite: [],
                    completion: $0
                )
            }
            assertFails(invalidType: true) {
                manager.requestPerObjectReadAuthorization(for: UnavailableType.unavailable, completion: $0)
            }
            assertFails(invalidType: true) {
                manager.requestPerObjectReadAuthorization(for: QuantityType.stepCount, completion: $0)
            }
            assertFails {
                manager.requestPerObjectReadAuthorization(
                    for: VisionPrescriptionType.visionPrescription,
                    completion: $0
                )
            }
        }
    }
    func testPreferredUnits() throws {
        let manager = reporter.manager
        let invalid = expectation(description: "invalid")
        manager.preferredUnits(for: []) { units, error in
            XCTAssertTrue(units.isEmpty)
            _ = error
            invalid.fulfill()
        }
        let failing = expectation(description: "failing")
        manager.preferredUnits(for: [.stepCount, .heartRate]) { units, error in
            XCTAssertTrue(units.isEmpty)
            XCTAssertNotNil(error)
            failing.fulfill()
        }
        wait(for: [invalid, failing], timeout: 30)
    }
    func testBackgroundDelivery() throws {
        let observer = reporter.observer
        assertFails(invalidType: true) {
            observer.enableBackgroundDelivery(type: UnavailableType.unavailable, completionHandler: $0)
        }
        assertFails(invalidType: true) {
            observer.disableBackgroundDelivery(type: UnavailableType.unavailable, completionHandler: $0)
        }
        for frequency in [UpdateFrequency.immediate, .hourly, .daily, .weekly] {
            assertFails {
                observer.enableBackgroundDelivery(
                    type: QuantityType.stepCount,
                    frequency: frequency,
                    completionHandler: $0
                )
            }
        }
        assertFails {
            observer.disableBackgroundDelivery(type: QuantityType.stepCount, completionHandler: $0)
        }
    }
    func testDeleteObjectsReachesHealthKit() throws {
        let expectation = expectation(description: "deletion")
        reporter.writer.deleteObjects(
            of: QuantityType.stepCount,
            predicate: .allSamples
        ) { success, _, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    #if os(iOS)
    func testStartWatchAppReachesHealthKit() throws {
        let configuration = WorkoutConfiguration(
            activityValue: 37,
            locationValue: 3,
            swimmingValue: 0,
            harmonized: WorkoutConfiguration.Harmonized(value: 400, unit: "m")
        )
        assertFails { self.reporter.manager.startWatchApp(with: configuration, completion: $0) }
    }
    #endif

    /// Calls the operation and checks it completed unsuccessfully, with a library error when **invalidType**
    private func assertFails(
        invalidType: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: (@escaping StatusCompletionBlock) -> Void
    ) {
        let expectation = expectation(description: "completion")
        var status: (success: Bool, error: Error?)?
        operation { success, error in
            status = (success, error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
        XCTAssertEqual(status?.success, false, file: file, line: line)
        if invalidType {
            assertInvalidType(try { throw try XCTUnwrap(status?.error) }(), file: file, line: line)
        }
    }
}
