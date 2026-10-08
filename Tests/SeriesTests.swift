//
//  SeriesTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class SeriesTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    private var values: [QuantitySeriesValue] {
        return [
            QuantitySeriesValue(
                value: 12,
                unit: "count",
                startTimestamp: startTimestamp,
                endTimestamp: startTimestamp + 10
            ),
            QuantitySeriesValue(
                value: 8,
                unit: "count",
                startTimestamp: startTimestamp + 10,
                endTimestamp: endTimestamp
            )
        ]
    }
    private var heartbeatSeries: HeartbeatSeries {
        return HeartbeatSeries(
            identifier: "HKDataTypeIdentifierHeartbeatSeries",
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: device,
            sourceRevision: sourceRevision,
            harmonized: HeartbeatSeries.Harmonized(
                count: 3,
                measurements: [
                    HeartbeatSeries.Measurement(timeSinceSeriesStart: 0, precededByGap: false, done: false),
                    HeartbeatSeries.Measurement(timeSinceSeriesStart: 0.8, precededByGap: false, done: false),
                    HeartbeatSeries.Measurement(timeSinceSeriesStart: 1.7, precededByGap: true, done: true)
                ],
                metadata: ["HKWasUserEntered": true]
            )
        )
    }

    func testSaveQuantitySeries() throws {
        let writer = HealthKitReporter().writer
        let error = try waitForStatus {
            writer.saveQuantitySeries(type: .stepCount, values: self.values, completion: $0)
        }
        XCTAssertEqual((error as NSError?)?.domain, HKErrorDomain)
        let invalid: [[QuantitySeriesValue]] = [
            [],
            [QuantitySeriesValue(value: 1, unit: "kg", startTimestamp: 0, endTimestamp: 1)],
            [QuantitySeriesValue(value: 1, unit: "count", startTimestamp: 1, endTimestamp: 0)]
        ]
        for values in invalid {
            let error = try waitForStatus {
                writer.saveQuantitySeries(type: .stepCount, values: values, completion: $0)
            }
            assertInvalidValue(try { throw try XCTUnwrap(error) }())
        }
    }
    func testSaveHeartbeatSeries() throws {
        let writer = HealthKitReporter().writer
        let error = try waitForStatus { writer.saveHeartbeatSeries(self.heartbeatSeries, completion: $0) }
        XCTAssertEqual((error as NSError?)?.domain, HKErrorDomain)
        let unordered = heartbeatSeries.copyWith(
            harmonized: heartbeatSeries.harmonized.copyWith(
                measurements: heartbeatSeries.harmonized.measurements.reversed()
            )
        )
        let invalidError = try waitForStatus { writer.saveHeartbeatSeries(unordered, completion: $0) }
        assertInvalidValue(try { throw try XCTUnwrap(invalidError) }())
    }

    private func waitForStatus(_ operation: (@escaping StatusCompletionBlock) -> Void) throws -> Error? {
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
}
