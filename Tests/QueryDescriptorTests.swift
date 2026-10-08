//
//  QueryDescriptorTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class QueryDescriptorTests: XCTestCase {
    /// **SampleType** without an original **HKSampleType**
    private enum UnavailableType: SampleType {
        case unavailable

        var identifier: String? {
            return nil
        }
    }

    private var descriptors: [QueryDescriptor] {
        return [
            QueryDescriptor(type: QuantityType.stepCount),
            QueryDescriptor(
                type: CategoryType.sleepAnalysis,
                predicate: NSPredicate.samplesPredicate(startDate: startDate, endDate: endDate)
            )
        ]
    }

    func testSampleQuery() throws {
        let sut = HealthKitReporter().reader
        XCTAssertNotNil(try sut.sampleQuery(descriptors: descriptors, limit: 4) { _, _, _ in })
        assertInvalidType(
            try sut.sampleQuery(
                descriptors: [QueryDescriptor(type: UnavailableType.unavailable)]
            ) { _, _, _ in }
        )
    }
    func testAnchoredObjectQuery() throws {
        let sut = HealthKitReporter().reader
        XCTAssertNotNil(
            try sut.anchoredObjectQuery(descriptors: descriptors, monitorUpdates: true) { _, _, _, _, _ in }
        )
        assertInvalidOption(
            try sut.anchoredObjectQuery(
                descriptors: descriptors,
                limit: 1,
                monitorUpdates: true
            ) { _, _, _, _, _ in }
        )
        assertInvalidType(
            try sut.anchoredObjectQuery(
                descriptors: [QueryDescriptor(type: UnavailableType.unavailable)]
            ) { _, _, _, _, _ in }
        )
    }
    func testObserverQuery() throws {
        let sut = HealthKitReporter().observer
        XCTAssertNotNil(
            try sut.observerQuery(descriptors: descriptors) { _, _, _, completion in
                completion()
            }
        )
        assertInvalidType(
            try sut.observerQuery(
                descriptors: [QueryDescriptor(type: UnavailableType.unavailable)]
            ) { _, _, _, completion in
                completion()
            }
        )
    }

    private func assertInvalidOption<T>(
        _ expression: @autoclosure () throws -> T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try expression(), file: file, line: line) { error in
            guard case HealthKitError.invalidOption = error else {
                XCTFail("Expected invalidOption, got \(error)", file: file, line: line)
                return
            }
        }
    }
}
