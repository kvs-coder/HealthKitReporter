//
//  MetadataTests.swift
//  
//
//  Created by Victor Kachalov on 29.10.22.
//

import XCTest
import HealthKitReporter

class MetadataTests: XCTestCase {
    func testMetadataString() {
        let metadataExpressible: Metadata = ["HKWasUserEntered": "1"]
        XCTAssertEqual(metadataExpressible, ["HKWasUserEntered": "1"])
        let metadataStringDictionary = Metadata.string(dictionary: ["HKWasUserEntered": "1"])
        XCTAssertEqual(metadataStringDictionary, ["HKWasUserEntered": "1"])
    }
    func testMetadataDate() {
        let date = Date()
        let metadataExpressible: Metadata = ["HKWasUserEnteredOn": date]
        XCTAssertEqual(metadataExpressible, ["HKWasUserEnteredOn": date])
        let metadataStringDictionary = Metadata.date(dictionary: ["HKWasUserEnteredOn": date])
        XCTAssertEqual(metadataStringDictionary, ["HKWasUserEnteredOn": date])
    }
    func testMetadataDouble() {
        let metadataExpressible: Metadata = ["HKWasUserEnteredValue": 10.0]
        XCTAssertEqual(metadataExpressible, ["HKWasUserEnteredValue": 10.0])
        let metadataStringDictionary = Metadata.double(dictionary: ["HKWasUserEnteredValue": 10.0])
        XCTAssertEqual(metadataStringDictionary, ["HKWasUserEnteredValue": 10.0])
    }
}
