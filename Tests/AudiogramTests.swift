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
    func testCollectAndParseResults() throws {
        let sample = HKAudiogramSample(
            sensitivityPoints: [
                try HKAudiogramSensitivityPoint(
                    frequency: HKQuantity(unit: .hertz(), doubleValue: 500),
                    leftEarSensitivity: HKQuantity(unit: .decibelHearingLevel(), doubleValue: 10),
                    rightEarSensitivity: HKQuantity(unit: .decibelHearingLevel(), doubleValue: 15)
                )
            ],
            start: startDate,
            end: endDate,
            metadata: nil
        )
        let sut = try XCTUnwrap(Audiogram.collect(results: [sample]).first)
        XCTAssertEqual(sut.uuid, sample.uuid.uuidString)
        XCTAssertEqual(sut.identifier, "HKDataTypeIdentifierAudiogram")
        let point = try XCTUnwrap(sut.harmonized.sensitivityPoints.first)
        XCTAssertEqual(point.frequency, 500, accuracy: 0.001)
        XCTAssertEqual(try XCTUnwrap(point.leftEarSensitivity), 10, accuracy: 0.001)
        XCTAssertEqual(try XCTUnwrap(point.rightEarSensitivity), 15, accuracy: 0.001)
        XCTAssertEqual((try parse([sample]).first as? Audiogram)?.uuid, sample.uuid.uuidString)
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
    func testAudiogramQuery() throws {
        let query = try HealthKitReporter().reader.audiogramQuery(limit: 3) { _, _ in }
        XCTAssertEqual(query.objectType?.identifier, "HKDataTypeIdentifierAudiogram")
        XCTAssertEqual(query.limit, 3)
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
