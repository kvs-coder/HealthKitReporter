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
    func testCreateThenEncodeThenDecode() throws {
        let date = Date(timeIntervalSince1970: 1626884800)
        let suts: [Metadata] = [
            .string(dictionary: ["HKWasUserEntered": "1"]),
            .date(dictionary: ["HKWasUserEnteredOn": date]),
            .double(dictionary: ["HKWasUserEnteredValue": 10.5]),
            .string(dictionary: nil)
        ]
        for sut in suts {
            let encoded = try sut.encoded()
            let decoded = try JSONDecoder().decode(
                Metadata.self,
                from: try XCTUnwrap(encoded.data(using: .utf8))
            )
            XCTAssertEqual(decoded, sut)
        }
    }
    func testCreateFromDictionary() throws {
        let date = Date(timeIntervalSince1970: 1626884800)
        XCTAssertEqual(
            try Metadata.make(from: ["HKWasUserEntered": "1"]),
            .string(dictionary: ["HKWasUserEntered": "1"])
        )
        XCTAssertEqual(
            try Metadata.make(from: ["HKWasUserEnteredOn": date]),
            .date(dictionary: ["HKWasUserEnteredOn": date])
        )
        XCTAssertEqual(
            try Metadata.make(from: ["HKWasUserEnteredValue": 10.5]),
            .double(dictionary: ["HKWasUserEnteredValue": 10.5])
        )
        let dictionary: [String: Any] = ["HKWasUserEntered": "1"]
        XCTAssertEqual(dictionary.asMetadata, .string(dictionary: ["HKWasUserEntered": "1"]))
    }
    func testCreateFromMixedDictionaryThrows() throws {
        let dictionary: [String: Any] = ["HKWasUserEntered": "1", "HKWasUserEnteredValue": 10.5]
        assertInvalidValue(try Metadata.make(from: dictionary))
        XCTAssertNil(dictionary.asMetadata)
    }
    func testOriginal() throws {
        let date = Date(timeIntervalSince1970: 1626884800)
        let string = try XCTUnwrap(Metadata.string(dictionary: ["key": "1"]).original as? [String: String])
        XCTAssertEqual(string, ["key": "1"])
        let dates = try XCTUnwrap(Metadata.date(dictionary: ["key": date]).original as? [String: Date])
        XCTAssertEqual(dates, ["key": date])
        let double = try XCTUnwrap(Metadata.double(dictionary: ["key": 1.5]).original as? [String: Double])
        XCTAssertEqual(double, ["key": 1.5])
        XCTAssertNil(Metadata.string(dictionary: nil).original)
    }
}
