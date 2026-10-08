//
//  ClinicalRecordTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

class ClinicalRecordTests: XCTestCase {
    private var harmonizedDictionary: [String: Any] {
        return [
            "displayName": "Penicillin",
            "fhirSourceUrl": "https://fhir.example.com/AllergyIntolerance/1",
            "fhirVersion": "4.0.1",
            "fhirData": "{\"resourceType\":\"AllergyIntolerance\"}",
            "metadata": [
                "HKWasUserEntered": "1"
            ]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKClinicalTypeIdentifierAllergyRecord",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": harmonizedDictionary
        ]
    }

    func testCreateThenEncodeThenDecode() throws {
        let sut = ClinicalRecord(
            identifier: ClinicalType.allergyRecord.identifier!,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: device,
            sourceRevision: sourceRevision,
            harmonized: ClinicalRecord.Harmonized(
                displayName: "Penicillin",
                fhirSourceUrl: "https://fhir.example.com/AllergyIntolerance/1",
                fhirVersion: "4.0.1",
                fhirData: "{\"resourceType\":\"AllergyIntolerance\"}",
                metadata: ["HKWasUserEntered": "1"]
            )
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            ClinicalRecord.self,
            from: try XCTUnwrap(encoded.data(using: .utf8))
        )
        XCTAssertEqual(decoded.uuid, sut.uuid)
        assertClinicalRecord(decoded)
    }
    func testCreateFromDictionary() throws {
        let sut = try ClinicalRecord.make(from: dictionary)
        assertClinicalRecord(sut)
    }
    func testCreateFromDictionaryWithoutOptionalFields() throws {
        var dictionary = dictionary
        dictionary.removeValue(forKey: "device")
        dictionary["harmonized"] = ["displayName": "Penicillin"]
        let sut = try ClinicalRecord.make(from: dictionary)
        XCTAssertNil(sut.device)
        XCTAssertEqual(sut.harmonized.displayName, "Penicillin")
        XCTAssertNil(sut.harmonized.fhirSourceUrl)
        XCTAssertNil(sut.harmonized.fhirVersion)
        XCTAssertNil(sut.harmonized.fhirData)
        XCTAssertNil(sut.harmonized.metadata)
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: dictionary,
            make: ClinicalRecord.make
        )
        assertEachKeyIsRequired(
            ["displayName"],
            in: harmonizedDictionary,
            make: ClinicalRecord.Harmonized.make
        )
    }
    func testCopyWithNoArgumentsKeepsAllFields() throws {
        let sut = try ClinicalRecord.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
    }
    func testCopyWithChangesOnlyGivenField() throws {
        let sut = try ClinicalRecord.make(from: dictionary)
        let copy = sut.copyWith(startTimestamp: 1)
        XCTAssertEqual(copy.startTimestamp, 1, accuracy: 0.001)
        XCTAssertEqual(
            try json(copy, excluding: ["startTimestamp"]),
            try json(sut, excluding: ["startTimestamp"])
        )
        let harmonized = sut.harmonized.copyWith(displayName: "Peanuts")
        XCTAssertEqual(harmonized.displayName, "Peanuts")
        XCTAssertEqual(
            try json(harmonized, excluding: ["displayName"]),
            try json(sut.harmonized, excluding: ["displayName"])
        )
    }
    func testCollectSkipsNonDictionaryElements() throws {
        let sut = try ClinicalRecord.collect(from: [dictionary, "invalid", 1, dictionary])
        XCTAssertEqual(sut.count, 2)
        assertClinicalRecord(sut[0])
        assertClinicalRecord(sut[1])
    }
    func testCollectThrowsOnInvalidDictionary() throws {
        assertInvalidValue(try ClinicalRecord.collect(from: [dictionary, ["identifier": "invalid"]]))
    }

    private func assertClinicalRecord(
        _ sut: ClinicalRecord,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.identifier, "HKClinicalTypeIdentifierAllergyRecord", file: file, line: line)
        XCTAssertEqual(sut.startTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.endTimestamp, 1626884860, accuracy: 0.001, file: file, line: line)
        assertDevice(sut.device, file: file, line: line)
        assertSourceRevision(sut.sourceRevision, file: file, line: line)
        XCTAssertEqual(sut.harmonized.displayName, "Penicillin", file: file, line: line)
        XCTAssertEqual(
            sut.harmonized.fhirSourceUrl,
            "https://fhir.example.com/AllergyIntolerance/1",
            file: file,
            line: line
        )
        XCTAssertEqual(sut.harmonized.fhirVersion, "4.0.1", file: file, line: line)
        XCTAssertEqual(
            sut.harmonized.fhirData,
            "{\"resourceType\":\"AllergyIntolerance\"}",
            file: file,
            line: line
        )
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": "1"], file: file, line: line)
    }
}
