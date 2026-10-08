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
        var original: HKObjectType? {
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
        let query = try HealthKitReporter().reader.sampleQuery(
            descriptors: descriptors,
            limit: 4
        ) { _, _, _ in }
        XCTAssertEqual(query.limit, 4)
        XCTAssertEqual(query.sortDescriptors?.first?.key, HKSampleSortIdentifierStartDate)
        assertInvalidType(
            try HealthKitReporter().reader.sampleQuery(
                descriptors: [QueryDescriptor(type: UnavailableType.unavailable)]
            ) { _, _, _ in }
        )
    }
    func testAnchoredObjectQueryParsesEveryType() throws {
        var parsed = [Sample]()
        let query = try HealthKitReporter().reader.anchoredObjectQuery(
            descriptors: descriptors,
            monitorUpdates: true
        ) { _, samples, _, _, _ in
            parsed = samples
        }
        let steps = HKQuantitySample(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 10),
            start: startDate,
            end: endDate
        )
        let sleep = HKCategorySample(
            type: HKCategoryType(.sleepAnalysis),
            value: HKCategoryValueSleepAnalysis.inBed.rawValue,
            start: startDate,
            end: endDate
        )
        try XCTUnwrap(query.updateHandler)(query, [steps, sleep], nil, nil, nil)
        XCTAssertNotNil(parsed.first as? Quantity)
        XCTAssertEqual(parsed.count, 2)
        XCTAssertEqual(parsed.last.map { String(describing: type(of: $0)) }, "Category")
        assertInvalidOption(
            try HealthKitReporter().reader.anchoredObjectQuery(
                descriptors: descriptors,
                limit: 1,
                monitorUpdates: true
            ) { _, _, _, _, _ in }
        )
    }
    func testObserverQuery() throws {
        let query = try HealthKitReporter().observer.observerQuery(
            descriptors: descriptors
        ) { _, _, _, completion in
            completion()
        }
        XCTAssertNil(query.objectType)
        assertInvalidType(
            try HealthKitReporter().observer.observerQuery(
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
