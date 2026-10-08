//
//  AudiogramTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class AudiogramTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    private var harmonizedDictionary: [String: Any] {
        return [
            "sensitivityPoints": [
                ["frequency": 500, "leftEarSensitivity": 10, "rightEarSensitivity": 15],
                ["frequency": 1000, "leftEarSensitivity": 20]
            ],
            "metadata": ["HKWasUserEntered": true]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKDataTypeIdentifierAudiogram",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": harmonizedDictionary
        ]
    }

    func testCreateFromDictionary() throws {
        assertAudiogram(try Audiogram.make(from: dictionary))
    }
    func testCreateThenEncodeThenDecode() throws {
        let sut = try Audiogram.make(from: dictionary)
        let decoded = try JSONDecoder().decode(
            Audiogram.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        XCTAssertEqual(decoded.uuid, sut.uuid)
        assertAudiogram(decoded)
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: dictionary,
            make: Audiogram.make
        )
        assertEachKeyIsRequired(
            ["sensitivityPoints"],
            in: harmonizedDictionary,
            make: Audiogram.Harmonized.make
        )
        assertInvalidValue(try Audiogram.Harmonized.make(from: ["sensitivityPoints": [["left": 1]]]))
    }
    func testCopyWith() throws {
        let sut = try Audiogram.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
        XCTAssertEqual(sut.copyWith(endTimestamp: 1).endTimestamp, 1)
    }
    func testSave() throws {
        let sut = try Audiogram.make(from: dictionary)
        XCTAssertEqual((try save(sut) as NSError?)?.domain, HKErrorDomain)
        let unordered = sut.copyWith(
            harmonized: sut.harmonized.copyWith(
                sensitivityPoints: sut.harmonized.sensitivityPoints.reversed()
            )
        )
        assertInvalidValue(try { throw try XCTUnwrap(try save(unordered)) }())
        let empty = sut.copyWith(harmonized: sut.harmonized.copyWith(sensitivityPoints: []))
        assertInvalidValue(try { throw try XCTUnwrap(try save(empty)) }())
    }

    private func assertAudiogram(
        _ sut: Audiogram,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.identifier, "HKDataTypeIdentifierAudiogram", file: file, line: line)
        XCTAssertEqual(sut.startTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.endTimestamp, 1626884860, accuracy: 0.001, file: file, line: line)
        assertDevice(sut.device, file: file, line: line)
        assertSourceRevision(sut.sourceRevision, file: file, line: line)
        let points = sut.harmonized.sensitivityPoints
        XCTAssertEqual(points.map(\.frequency), [500, 1000], file: file, line: line)
        XCTAssertEqual(points.map(\.leftEarSensitivity), [10, 20], file: file, line: line)
        XCTAssertEqual(points.map(\.rightEarSensitivity), [15, nil], file: file, line: line)
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": true], file: file, line: line)
    }
}

// MARK: - Identity
extension AudiogramTests {
    func testCreateFromDictionaryKeepsUUID() throws {
        try assertMakeKeepsUUID(from: dictionary, make: Audiogram.make)
    }
    func testCopyWithKeepsUUID() throws {
        let sut = try Audiogram.make(from: dictionary)
        XCTAssertEqual(sut.copyWith(startTimestamp: 1).uuid, sut.uuid)
    }
}
