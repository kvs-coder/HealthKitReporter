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
