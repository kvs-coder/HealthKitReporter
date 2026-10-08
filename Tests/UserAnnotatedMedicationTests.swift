//
//  UserAnnotatedMedicationTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

@available(iOS 26.0, watchOS 26.0, *)
class UserAnnotatedMedicationTests: XCTestCase {
    private var dictionary: [String: Any] {
        return [
            "nickname": "Morning pill",
            "isArchived": false,
            "hasSchedule": true,
            "medication": [
                "identifier": "YXJjaGl2ZWQ=",
                "domain": "medication",
                "displayText": "Ibuprofen 200 mg Oral Tablet",
                "generalForm": "tablet",
                "relatedCodings": [
                    ["system": "http://www.nlm.nih.gov/research/umls/rxnorm", "code": "310965"]
                ]
            ]
        ]
    }

    func testCreateFromDictionaryThenEncodeThenDecode() throws {
        let sut = try UserAnnotatedMedication.make(from: dictionary)
        let decoded = try JSONDecoder().decode(
            UserAnnotatedMedication.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        for medication in [sut, decoded] {
            XCTAssertEqual(medication.nickname, "Morning pill")
            XCTAssertFalse(medication.isArchived)
            XCTAssertTrue(medication.hasSchedule)
            XCTAssertEqual(medication.medication.identifier, "YXJjaGl2ZWQ=")
            XCTAssertEqual(medication.medication.domain, "medication")
            XCTAssertEqual(medication.medication.displayText, "Ibuprofen 200 mg Oral Tablet")
            XCTAssertEqual(medication.medication.generalForm, "tablet")
            XCTAssertEqual(medication.medication.relatedCodings.map(\.code), ["310965"])
            XCTAssertNil(medication.medication.relatedCodings.first?.version)
        }
        assertEachKeyIsRequired(
            ["isArchived", "hasSchedule", "medication"],
            in: dictionary,
            make: UserAnnotatedMedication.make
        )
    }
}
