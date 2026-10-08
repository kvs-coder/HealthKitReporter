//
//  StateOfMindTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

@available(iOS 18.0, watchOS 11.0, *)
class StateOfMindTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    private var harmonizedDictionary: [String: Any] {
        return [
            "kind": 1,
            "valence": 0.5,
            "valenceClassification": 6,
            "labels": [17, 7],
            "associations": [8],
            "metadata": ["HKWasUserEntered": true]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKDataTypeStateOfMind",
            "startTimestamp": startTimestamp,
            "endTimestamp": startTimestamp,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": harmonizedDictionary
        ]
    }

    func testCreateFromDictionary() throws {
        assertStateOfMind(try StateOfMind.make(from: dictionary))
    }
    func testCreateThenEncodeThenDecode() throws {
        let sut = try StateOfMind.make(from: dictionary)
        let decoded = try JSONDecoder().decode(
            StateOfMind.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        XCTAssertEqual(decoded.uuid, sut.uuid)
        assertStateOfMind(decoded)
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: dictionary,
            make: StateOfMind.make
        )
        assertEachKeyIsRequired(
            ["kind", "valence", "labels", "associations"],
            in: harmonizedDictionary,
            make: StateOfMind.Harmonized.make
        )
    }
    func testCopyWith() throws {
        let sut = try StateOfMind.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
        XCTAssertEqual(sut.harmonized.copyWith(valence: -1).valence, -1)
    }
    func testSave() throws {
        let sut = try StateOfMind.make(from: dictionary)
        XCTAssertEqual((try save(sut) as NSError?)?.domain, HKErrorDomain)
        let invalid: [StateOfMind.Harmonized] = [
            sut.harmonized.copyWith(valence: 2),
            sut.harmonized.copyWith(kind: 3),
            sut.harmonized.copyWith(labels: [99]),
            sut.harmonized.copyWith(associations: [0])
        ]
        for harmonized in invalid {
            assertInvalidValue(try { throw try XCTUnwrap(try save(sut.copyWith(harmonized: harmonized))) }())
        }
    }

    private func assertStateOfMind(
        _ sut: StateOfMind,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.identifier, "HKDataTypeStateOfMind", file: file, line: line)
        XCTAssertEqual(sut.startTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        XCTAssertNil(sut.device, file: file, line: line)
        assertSourceRevision(sut.sourceRevision, file: file, line: line)
        XCTAssertEqual(sut.harmonized.kind, 1, file: file, line: line)
        XCTAssertEqual(sut.harmonized.valence, 0.5, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.harmonized.valenceClassification, 6, file: file, line: line)
        XCTAssertEqual(sut.harmonized.labels, [17, 7], file: file, line: line)
        XCTAssertEqual(sut.harmonized.associations, [8], file: file, line: line)
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": true], file: file, line: line)
    }
}

// MARK: - Identity
@available(iOS 18.0, watchOS 11.0, *)
extension StateOfMindTests {
    func testCreateFromDictionaryKeepsUUID() throws {
        try assertMakeKeepsUUID(from: dictionary, make: StateOfMind.make)
    }
    func testCopyWithKeepsUUID() throws {
        let sut = try StateOfMind.make(from: dictionary)
        XCTAssertEqual(sut.copyWith(startTimestamp: 1).uuid, sut.uuid)
    }
}
