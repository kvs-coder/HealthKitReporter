//
//  HealthKitObserverTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class HealthKitObserverTests: XCTestCase {
    /// **SampleType** without an original **HKSampleType**
    private enum UnavailableType: SampleType {
        case unavailable

        var identifier: String? {
            return nil
        }
    }

    private var sut: HealthKitObserver!

    override func setUp() {
        super.setUp()
        sut = HealthKitReporter().observer
    }
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testObserverQueryWithInvalidType() throws {
        assertInvalidType(try sut.observerQuery(type: UnavailableType.unavailable) { _, _, _ in })
        assertInvalidType(
            try sut.observerQuery(type: UnavailableType.unavailable) { _, _, _, completion in
                completion()
            }
        )
    }
}
