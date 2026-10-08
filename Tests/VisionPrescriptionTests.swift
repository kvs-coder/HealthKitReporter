//
//  VisionPrescriptionTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

class VisionPrescriptionTests: XCTestCase {
    private var prescriptionTypeDictionary: [String: Any] {
        return [
            "id": 1,
            "detail": "glasses"
        ]
    }
    private var harmonizedDictionary: [String: Any] {
        return [
            "dateIssuedTimestamp": startTimestamp,
            "expirationDateTimestamp": endTimestamp,
            "prescriptionType": prescriptionTypeDictionary,
            "metadata": [
                "HKWasUserEntered": "1"
            ]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKVisionPrescriptionTypeIdentifier",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": harmonizedDictionary
        ]
    }

    func testCreateFromDictionary() throws {
        guard #available(iOS 16.0, *) else {
            throw XCTSkip("VisionPrescription requires iOS 16")
        }
        let sut = try VisionPrescription.make(from: dictionary)
        assertVisionPrescription(sut)
    }
    func testCreateThenEncodeThenDecode() throws {
        guard #available(iOS 16.0, *) else {
            throw XCTSkip("VisionPrescription requires iOS 16")
        }
        let sut = try VisionPrescription.make(from: dictionary)
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            VisionPrescription.self,
            from: try XCTUnwrap(encoded.data(using: .utf8))
        )
        XCTAssertEqual(decoded.uuid, sut.uuid)
        assertVisionPrescription(decoded)
    }
    func testCreateFromDictionaryWithoutOptionalFields() throws {
        guard #available(iOS 16.0, *) else {
            throw XCTSkip("VisionPrescription requires iOS 16")
        }
        var harmonized = harmonizedDictionary
        harmonized.removeValue(forKey: "expirationDateTimestamp")
        harmonized.removeValue(forKey: "metadata")
        var dictionary = dictionary
        dictionary.removeValue(forKey: "device")
        dictionary["harmonized"] = harmonized
        let sut = try VisionPrescription.make(from: dictionary)
        XCTAssertNil(sut.device)
        XCTAssertNil(sut.harmonized.expirationDateTimestamp)
        XCTAssertNil(sut.harmonized.metadata)
    }
    func testCreateFromInvalidDictionary() throws {
        guard #available(iOS 16.0, *) else {
            throw XCTSkip("VisionPrescription requires iOS 16")
        }
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: dictionary,
            make: VisionPrescription.make
        )
        assertEachKeyIsRequired(
            ["dateIssuedTimestamp", "prescriptionType"],
            in: harmonizedDictionary,
            make: VisionPrescription.Harmonized.make
        )
        assertEachKeyIsRequired(
            ["id", "detail"],
            in: prescriptionTypeDictionary,
            make: VisionPrescription.PrescriptionType.make
        )
    }

    @available(iOS 16.0, *)
    private func assertVisionPrescription(
        _ sut: VisionPrescription,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.identifier, "HKVisionPrescriptionTypeIdentifier", file: file, line: line)
        XCTAssertEqual(sut.startTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.endTimestamp, 1626884860, accuracy: 0.001, file: file, line: line)
        assertDevice(sut.device, file: file, line: line)
        assertSourceRevision(sut.sourceRevision, file: file, line: line)
        XCTAssertEqual(
            sut.harmonized.dateIssuedTimestamp,
            1626884800,
            accuracy: 0.001,
            file: file,
            line: line
        )
        XCTAssertEqual(
            sut.harmonized.expirationDateTimestamp ?? 0,
            1626884860,
            accuracy: 0.001,
            file: file,
            line: line
        )
        XCTAssertEqual(sut.harmonized.prescriptionType.id, 1, file: file, line: line)
        XCTAssertEqual(sut.harmonized.prescriptionType.detail, "glasses", file: file, line: line)
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": "1"], file: file, line: line)
    }
}
