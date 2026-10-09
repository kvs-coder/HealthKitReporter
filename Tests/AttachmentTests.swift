//
//  AttachmentTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class AttachmentTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    private var dictionary: [String: Any] {
        return [
            "identifier": "BA0ADD39-638C-4FF8-AF48-0FC88CDCC48A",
            "name": "prescription.jpg",
            "contentType": "public.jpeg",
            "size": 2048,
            "creationTimestamp": startTimestamp,
            "metadata": ["HKWasUserEntered": true]
        ]
    }

    func testCreateFromDictionaryThenEncodeThenDecode() throws {
        let sut = try Attachment.make(from: dictionary)
        let decoded = try JSONDecoder().decode(
            Attachment.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        for attachment in [sut, decoded] {
            XCTAssertEqual(attachment.identifier, "BA0ADD39-638C-4FF8-AF48-0FC88CDCC48A")
            XCTAssertEqual(attachment.name, "prescription.jpg")
            XCTAssertEqual(attachment.contentType, "public.jpeg")
            XCTAssertEqual(attachment.size, 2048)
            XCTAssertEqual(attachment.creationTimestamp, 1626884800, accuracy: 0.001)
            XCTAssertEqual(attachment.metadata, ["HKWasUserEntered": true])
        }
        assertEachKeyIsRequired(
            ["identifier", "name", "contentType", "size", "creationTimestamp"],
            in: dictionary,
            make: Attachment.make
        )
    }
    func testAttachmentOperationsOnMissingSamplesComplete() throws {
        guard #available(iOS 16.0, watchOS 9.0, *) else {
            throw XCTSkip("Attachments require iOS 16")
        }
        let manager = HealthKitReporter().manager
        let type = VisionPrescriptionType.visionPrescription
        let missing = UUID().uuidString
        let listed = expectation(description: "attachments")
        manager.attachments(forSampleOf: type, uuid: missing) { attachments, error in
            XCTAssertTrue(attachments.isEmpty)
            XCTAssertNotNil(error)
            listed.fulfill()
        }
        let read = expectation(description: "data")
        manager.attachmentData(
            forSampleOf: type,
            uuid: missing,
            attachmentIdentifier: missing
        ) { data, error in
            XCTAssertNil(data)
            XCTAssertNotNil(error)
            read.fulfill()
        }
        let removed = expectation(description: "remove")
        manager.removeAttachment(
            fromSampleOf: type,
            uuid: missing,
            attachmentIdentifier: missing
        ) { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            removed.fulfill()
        }
        wait(for: [listed, read, removed], timeout: 30)
        var added: (attachment: Attachment?, error: Error?)?
        manager.addAttachment(
            toSampleOf: type,
            uuid: missing,
            name: "scan",
            contentType: "not a type",
            url: URL(fileURLWithPath: "/tmp/scan.jpg")
        ) { attachment, error in
            added = (attachment, error)
        }
        XCTAssertNil(added?.attachment)
        assertInvalidValue(try { throw try XCTUnwrap(added?.error) }())
        var invalidMetadata: Error?
        manager.addAttachment(
            toSampleOf: type,
            uuid: missing,
            name: "scan",
            contentType: "public.jpeg",
            url: URL(fileURLWithPath: "/tmp/scan.jpg"),
            metadata: ["HKLapLength": .quantity(value: 25, unit: "notAUnit")]
        ) { _, error in
            invalidMetadata = error
        }
        assertInvalidValue(try { throw try XCTUnwrap(invalidMetadata) }())
        let notStored = expectation(description: "not stored")
        manager.addAttachment(
            toSampleOf: type,
            uuid: missing,
            name: "scan",
            contentType: "public.jpeg",
            url: URL(fileURLWithPath: "/tmp/scan.jpg"),
            metadata: ["HKWasUserEntered": true]
        ) { attachment, error in
            XCTAssertNil(attachment)
            XCTAssertNotNil(error)
            notStored.fulfill()
        }
        wait(for: [notStored], timeout: 30)
        var invalidUUID: Error?
        manager.attachments(forSampleOf: type, uuid: "not a uuid") { _, error in
            invalidUUID = error
        }
        assertInvalidValue(try { throw try XCTUnwrap(invalidUUID) }())
    }
}
