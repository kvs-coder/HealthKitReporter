//
//  DeletedObjectTests.swift
//  
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

class DeletedObjectTests: XCTestCase {
    private var dictionary: [String: Any] {
        return [
            "uuid": "BA0ADD39-638C-4FF8-AF48-0FC88CDCC48A",
            "metadata": [
                "string": [
                    "dictionary": [
                        "HKWasUserEntered": "1"
                    ]
                ]
            ]
        ]
    }

    func testCreateFromDictionary() throws {
        let sut = try decode(DeletedObject.self, from: dictionary)
        XCTAssertEqual(sut.uuid, "BA0ADD39-638C-4FF8-AF48-0FC88CDCC48A")
        XCTAssertEqual(sut.metadata, ["HKWasUserEntered": "1"])
    }
    func testCreateThenEncodeThenDecode() throws {
        let sut = try decode(DeletedObject.self, from: dictionary)
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            DeletedObject.self,
            from: try XCTUnwrap(encoded.data(using: .utf8))
        )
        XCTAssertEqual(decoded.uuid, "BA0ADD39-638C-4FF8-AF48-0FC88CDCC48A")
        XCTAssertEqual(decoded.metadata, ["HKWasUserEntered": "1"])
    }
    func testCreateFromDictionaryWithoutMetadata() throws {
        let sut = try decode(
            DeletedObject.self,
            from: ["uuid": "BA0ADD39-638C-4FF8-AF48-0FC88CDCC48A"]
        )
        XCTAssertEqual(sut.uuid, "BA0ADD39-638C-4FF8-AF48-0FC88CDCC48A")
        XCTAssertNil(sut.metadata)
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["uuid"],
            in: dictionary,
            decoding: DeletedObject.self
        )
    }
    func testCollectFromNoDeletedObjects() throws {
        XCTAssertTrue(DeletedObject.collect(deletedObjects: nil).isEmpty)
        XCTAssertTrue(DeletedObject.collect(deletedObjects: []).isEmpty)
    }
}
