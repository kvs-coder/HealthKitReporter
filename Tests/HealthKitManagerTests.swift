//
//  HealthKitManagerTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class HealthKitManagerTests: XCTestCase {
    /// **SampleType** without an original **HKSampleType**
    private enum UnavailableType: SampleType {
        case unavailable

        var identifier: String? {
            return nil
        }
        var original: HKObjectType? {
            return nil
        }
    }

    private var sut: HealthKitManager!

    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }
    override func setUp() {
        super.setUp()
        sut = HealthKitReporter().manager
    }
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testAuthorizationRequestStatus() throws {
        let expectation = expectation(description: "status")
        var result: (status: AuthorizationRequestStatus, error: Error?)?
        sut.authorizationRequestStatus(
            toRead: [QuantityType.stepCount],
            toWrite: [CategoryType.sleepAnalysis]
        ) { status, error in
            result = (status, error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
        XCTAssertNotNil(result)
        var invalid: (status: AuthorizationRequestStatus, error: Error?)?
        sut.authorizationRequestStatus(toRead: [UnavailableType.unavailable], toWrite: []) { status, error in
            invalid = (status, error)
        }
        XCTAssertEqual(invalid?.status, .unknown)
        assertInvalidType(try { throw try XCTUnwrap(invalid?.error) }())
    }
    func testAuthorizationRequestStatusRawValues() throws {
        XCTAssertEqual(AuthorizationRequestStatus.unknown.rawValue, 0)
        XCTAssertEqual(AuthorizationRequestStatus.shouldRequest.rawValue, 1)
        XCTAssertEqual(AuthorizationRequestStatus.unnecessary.rawValue, 2)
    }
    func testEarliestPermittedSampleDate() throws {
        XCTAssertEqual(sut.earliestPermittedSampleDate(), HKHealthStore().earliestPermittedSampleDate())
    }
    func testRecalibrateEstimates() throws {
        var status: (success: Bool, error: Error?)?
        sut.recalibrateEstimates(for: QuantityType.stepCount, at: startDate) { success, error in
            status = (success, error)
        }
        XCTAssertEqual(status?.success, false)
        assertInvalidType(try { throw try XCTUnwrap(status?.error) }())
        let expectation = expectation(description: "recalibration")
        sut.recalibrateEstimates(for: QuantityType.sixMinuteWalkTestDistance, at: startDate) { _, _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
}
