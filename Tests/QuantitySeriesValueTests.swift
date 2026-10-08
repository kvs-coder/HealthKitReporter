//
//  QuantitySeriesValueTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class QuantitySeriesValueTests: XCTestCase {
    func testCreateFromDictionaryThenEncodeThenDecode() throws {
        let dictionary: [String: Any] = [
            "value": 12,
            "unit": "count",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "sampleUUID": "BA0ADD39-638C-4FF8-AF48-0FC88CDCC48A"
        ]
        let sut = try QuantitySeriesValue.make(from: dictionary)
        let decoded = try JSONDecoder().decode(
            QuantitySeriesValue.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        for value in [sut, decoded] {
            XCTAssertEqual(value.value, 12, accuracy: 0.001)
            XCTAssertEqual(value.unit, "count")
            XCTAssertEqual(value.startTimestamp, 1626884800, accuracy: 0.001)
            XCTAssertEqual(value.endTimestamp, 1626884860, accuracy: 0.001)
            XCTAssertEqual(value.sampleUUID, "BA0ADD39-638C-4FF8-AF48-0FC88CDCC48A")
        }
        assertEachKeyIsRequired(
            ["value", "unit", "startTimestamp", "endTimestamp"],
            in: dictionary,
            make: QuantitySeriesValue.make
        )
    }
}
