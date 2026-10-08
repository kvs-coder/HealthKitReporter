//
//  EncodableTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

class EncodableTests: XCTestCase {
    func testEncodeNonFiniteNumbersAsStringsDartCanParse() throws {
        let values: [(Double, String)] = [
            (.infinity, "Infinity"),
            (-.infinity, "-Infinity"),
            (.nan, "NaN")
        ]
        for (value, expected) in values {
            let sut = Quantity.Harmonized(value: value, unit: "count", metadata: nil)
            XCTAssertEqual(try json(sut)["value"] as? String, expected)
        }
    }
    func testEncodeFiniteNumbersAsNumbers() throws {
        let sut = Quantity.Harmonized(value: 1.5, unit: "count", metadata: nil)
        XCTAssertEqual(try json(sut)["value"] as? Double, 1.5)
    }
}
