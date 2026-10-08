//
//  VerifiableClinicalRecordTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

class VerifiableClinicalRecordTests: XCTestCase {
    private var harmonizedDictionary: [String: Any] {
        return [
            "recordTypes": ["https://smarthealth.cards#immunization"],
            "issuerIdentifier": "https://spec.smarthealth.cards/examples/issuer",
            "subject": [
                "fullName": "John B. Anyperson",
                "dateOfBirth": "1951-01-20T00:00:00.000+01:00"
            ],
            "issuedTimestamp": startTimestamp,
            "relevantTimestamp": startTimestamp,
            "expirationTimestamp": endTimestamp,
            "itemNames": ["COVID-19 Vaccination"],
            "sourceType": "https://smarthealth.cards",
            "dataRepresentation": "ZXlKaGJHY2lPaUpGVXpJMU5pSjk="
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKVerifiableClinicalRecordTypeIdentifier",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": harmonizedDictionary
        ]
    }

    func testCreateFromDictionary() throws {
        assertRecord(try VerifiableClinicalRecord.make(from: dictionary))
    }
    func testCreateThenEncodeThenDecode() throws {
        let sut = try VerifiableClinicalRecord.make(from: dictionary)
        let decoded = try JSONDecoder().decode(
            VerifiableClinicalRecord.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        XCTAssertEqual(decoded.uuid, sut.uuid)
        assertRecord(decoded)
    }
    func testCreateFromDictionaryWithoutOptionalFields() throws {
        var harmonized = harmonizedDictionary
        harmonized.removeValue(forKey: "expirationTimestamp")
        harmonized.removeValue(forKey: "sourceType")
        harmonized["subject"] = ["fullName": "John B. Anyperson"]
        var dictionary = dictionary
        dictionary["harmonized"] = harmonized
        dictionary.removeValue(forKey: "device")
        let sut = try VerifiableClinicalRecord.make(from: dictionary)
        XCTAssertNil(sut.device)
        XCTAssertNil(sut.harmonized.expirationTimestamp)
        XCTAssertNil(sut.harmonized.sourceType)
        XCTAssertNil(sut.harmonized.subject.dateOfBirth)
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: dictionary,
            make: VerifiableClinicalRecord.make
        )
        assertEachKeyIsRequired(
            [
                "recordTypes", "issuerIdentifier", "subject", "issuedTimestamp",
                "relevantTimestamp", "itemNames", "dataRepresentation"
            ],
            in: harmonizedDictionary,
            make: VerifiableClinicalRecord.Harmonized.make
        )
    }

    private func assertRecord(
        _ sut: VerifiableClinicalRecord,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.identifier, "HKVerifiableClinicalRecordTypeIdentifier", file: file, line: line)
        XCTAssertEqual(sut.startTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.endTimestamp, 1626884860, accuracy: 0.001, file: file, line: line)
        assertDevice(sut.device, file: file, line: line)
        assertSourceRevision(sut.sourceRevision, file: file, line: line)
        let harmonized = sut.harmonized
        XCTAssertEqual(
            harmonized.recordTypes,
            ["https://smarthealth.cards#immunization"],
            file: file,
            line: line
        )
        XCTAssertEqual(
            harmonized.issuerIdentifier,
            "https://spec.smarthealth.cards/examples/issuer",
            file: file,
            line: line
        )
        XCTAssertEqual(harmonized.subject.fullName, "John B. Anyperson", file: file, line: line)
        XCTAssertEqual(
            harmonized.subject.dateOfBirth,
            "1951-01-20T00:00:00.000+01:00",
            file: file,
            line: line
        )
        XCTAssertEqual(harmonized.issuedTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(harmonized.relevantTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(
            harmonized.expirationTimestamp ?? 0,
            1626884860,
            accuracy: 0.001,
            file: file,
            line: line
        )
        XCTAssertEqual(harmonized.itemNames, ["COVID-19 Vaccination"], file: file, line: line)
        XCTAssertEqual(harmonized.sourceType, "https://smarthealth.cards", file: file, line: line)
        XCTAssertEqual(
            harmonized.dataRepresentation,
            "ZXlKaGJHY2lPaUpGVXpJMU5pSjk=",
            file: file,
            line: line
        )
    }
}
