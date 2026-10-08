//
//  MedicationDoseEventTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

@available(iOS 26.0, watchOS 26.0, *)
class MedicationDoseEventTests: XCTestCase {
    private var doseEventDictionary: [String: Any] {
        return [
            "identifier": "HKMedicationDoseEventTypeIdentifierMedicationDoseEvent",
            "startTimestamp": startTimestamp,
            "endTimestamp": startTimestamp,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": [
                "scheduleType": 2,
                "medicationConceptIdentifier": "YXJjaGl2ZWQ=",
                "scheduledTimestamp": startTimestamp,
                "scheduledDoseQuantity": 1,
                "doseQuantity": 1,
                "logStatus": 4,
                "unit": "count",
                "metadata": ["HKWasUserEntered": true]
            ]
        ]
    }

    func testCreateFromDictionaryThenEncodeThenDecode() throws {
        let sut = try MedicationDoseEvent.make(from: doseEventDictionary)
        let decoded = try JSONDecoder().decode(
            MedicationDoseEvent.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        for doseEvent in [sut, decoded] {
            XCTAssertEqual(doseEvent.identifier, "HKMedicationDoseEventTypeIdentifierMedicationDoseEvent")
            XCTAssertEqual(doseEvent.startTimestamp, 1626884800, accuracy: 0.001)
            assertSourceRevision(doseEvent.sourceRevision)
            XCTAssertEqual(doseEvent.harmonized.scheduleType, 2)
            XCTAssertEqual(doseEvent.harmonized.medicationConceptIdentifier, "YXJjaGl2ZWQ=")
            let scheduledTimestamp = try XCTUnwrap(doseEvent.harmonized.scheduledTimestamp)
            XCTAssertEqual(scheduledTimestamp, 1626884800, accuracy: 0.001)
            XCTAssertEqual(doseEvent.harmonized.scheduledDoseQuantity, 1)
            XCTAssertEqual(doseEvent.harmonized.doseQuantity, 1)
            XCTAssertEqual(doseEvent.harmonized.logStatus, 4)
            XCTAssertEqual(doseEvent.harmonized.unit, "count")
            XCTAssertEqual(doseEvent.harmonized.metadata, ["HKWasUserEntered": true])
        }
        assertEachKeyIsRequired(
            ["scheduleType", "medicationConceptIdentifier", "logStatus", "unit"],
            in: try XCTUnwrap(doseEventDictionary["harmonized"] as? [String: Any]),
            make: MedicationDoseEvent.Harmonized.make
        )
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: doseEventDictionary,
            make: MedicationDoseEvent.make
        )
    }
}
// MARK: - Identity
@available(iOS 26.0, watchOS 26.0, *)
extension MedicationDoseEventTests {
    func testCreateFromDictionaryKeepsUUID() throws {
        try assertMakeKeepsUUID(from: doseEventDictionary, make: MedicationDoseEvent.make)
    }
}
