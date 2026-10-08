//
//  CDADocumentTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

#if os(iOS)
import XCTest
import HealthKit
import HealthKitReporter

class CDADocumentTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    /// Minimal document meeting the CDA requirements HealthKit validates
    private let xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <ClinicalDocument xmlns="urn:hl7-org:v3">
      <realmCode code="US"/>
      <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
      <templateId root="2.16.840.1.113883.10.20.22.1.1"/>
      <id root="2.16.840.1.113883.19.5.99999.1"/>
      <code code="34133-9" codeSystem="2.16.840.1.113883.6.1"/>
      <title>Summary of Care</title>
      <effectiveTime value="20210721"/>
      <confidentialityCode code="N" codeSystem="2.16.840.1.113883.5.25"/>
      <recordTarget><patientRole><id root="1"/><patient>
        <name><given>John</given><family>Doe</family></name>
      </patient></patientRole></recordTarget>
      <author><time value="20210721"/><assignedAuthor><id root="2"/><assignedPerson>
        <name><given>Jane</given><family>Smith</family></name>
      </assignedPerson></assignedAuthor></author>
      <custodian><assignedCustodian><representedCustodianOrganization><id root="3"/>
        <name>Good Health Clinic</name>
      </representedCustodianOrganization></assignedCustodian></custodian>
      <component><structuredBody><component><section>
        <title>Notes</title><text>None</text>
      </section></component></structuredBody></component>
    </ClinicalDocument>
    """
    private var harmonizedDictionary: [String: Any] {
        return [
            "title": "Summary of Care",
            "patientName": "John Doe",
            "authorName": "Jane Smith",
            "custodianName": "Good Health Clinic",
            "documentData": Data(xml.utf8).base64EncodedString(),
            "metadata": ["HKWasUserEntered": true]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKDocumentTypeIdentifierCDA",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": harmonizedDictionary
        ]
    }

    func testCreateFromDictionary() throws {
        assertDocument(try CDADocument.make(from: dictionary))
    }
    func testCreateThenEncodeThenDecode() throws {
        let sut = try CDADocument.make(from: dictionary)
        let decoded = try JSONDecoder().decode(
            CDADocument.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        XCTAssertEqual(decoded.uuid, sut.uuid)
        assertDocument(decoded)
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: dictionary,
            make: CDADocument.make
        )
    }
    func testCopyWith() throws {
        let sut = try CDADocument.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
        XCTAssertEqual(sut.harmonized.copyWith(title: "Other").title, "Other")
        XCTAssertEqual(sut.copyWith(endTimestamp: 1).endTimestamp, 1)
    }
    func testCollectResults() throws {
        let sample = try HKCDADocumentSample(
            data: Data(xml.utf8),
            start: startDate,
            end: endDate,
            metadata: [HKMetadataKeyWasUserEntered: true]
        )
        let sut = try XCTUnwrap(CDADocument.collect(results: [sample]).first)
        XCTAssertEqual(sut.uuid, sample.uuid.uuidString)
        XCTAssertEqual(sut.identifier, "HKDocumentTypeIdentifierCDA")
        // HealthKit takes the dates from the document's effectiveTime
        XCTAssertEqual(sut.startTimestamp, sample.startDate.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(sut.harmonized.title, "Summary of Care")
        XCTAssertEqual(sut.harmonized.documentData, Data(xml.utf8).base64EncodedString())
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": true])
        XCTAssertEqual((try parse([sample]).first as? CDADocument)?.uuid, sample.uuid.uuidString)
        let other = HKQuantitySample(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 1),
            start: startDate,
            end: endDate
        )
        XCTAssertTrue(CDADocument.collect(results: [other]).isEmpty)
    }
    func testSave() throws {
        let sut = try CDADocument.make(from: dictionary)
        XCTAssertEqual((try save(sut) as NSError?)?.domain, HKErrorDomain)
        let invalid = sut.copyWith(harmonized: sut.harmonized.copyWith(documentData: "not base64"))
        assertInvalidValue(try { throw try XCTUnwrap(try save(invalid)) }())
    }
    func testDocumentQuery() throws {
        let predicate = NSPredicate.samplesPredicate(startDate: startDate, endDate: endDate)
        let query = try HealthKitReporter().reader.cdaDocumentQuery(
            predicate: predicate,
            limit: 5,
            includeDocumentData: false
        ) { _, _, _ in }
        XCTAssertEqual(query.objectType?.identifier, "HKDocumentTypeIdentifierCDA")
        XCTAssertEqual(query.predicate, predicate)
        XCTAssertEqual(query.limit, 5)
        XCTAssertFalse(query.includeDocumentData)
    }

    private func assertDocument(
        _ sut: CDADocument,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.identifier, "HKDocumentTypeIdentifierCDA", file: file, line: line)
        XCTAssertEqual(sut.startTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.endTimestamp, 1626884860, accuracy: 0.001, file: file, line: line)
        assertDevice(sut.device, file: file, line: line)
        assertSourceRevision(sut.sourceRevision, file: file, line: line)
        XCTAssertEqual(sut.harmonized.title, "Summary of Care", file: file, line: line)
        XCTAssertEqual(sut.harmonized.patientName, "John Doe", file: file, line: line)
        XCTAssertEqual(sut.harmonized.authorName, "Jane Smith", file: file, line: line)
        XCTAssertEqual(sut.harmonized.custodianName, "Good Health Clinic", file: file, line: line)
        XCTAssertEqual(
            sut.harmonized.documentData,
            Data(xml.utf8).base64EncodedString(),
            file: file,
            line: line
        )
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": true], file: file, line: line)
    }
}
#endif
