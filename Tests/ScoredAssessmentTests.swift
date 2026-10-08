//
//  ScoredAssessmentTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

@available(iOS 18.0, watchOS 11.0, *)
class ScoredAssessmentTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    private var dictionary: [String: Any] {
        return [
            "identifier": "HKScoredAssessmentTypeIdentifierGAD7",
            "startTimestamp": startTimestamp,
            "endTimestamp": startTimestamp,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": [
                "answers": [0, 1, 2, 3, 0, 1, 2],
                "score": 9,
                "risk": 2,
                "metadata": ["HKWasUserEntered": true]
            ]
        ]
    }

    func testCreateFromDictionary() throws {
        assertAssessment(try ScoredAssessment.make(from: dictionary))
    }
    func testCreateThenEncodeThenDecode() throws {
        let sut = try ScoredAssessment.make(from: dictionary)
        let decoded = try JSONDecoder().decode(
            ScoredAssessment.self,
            from: try XCTUnwrap(sut.encoded().data(using: .utf8))
        )
        XCTAssertEqual(decoded.uuid, sut.uuid)
        assertAssessment(decoded)
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: dictionary,
            make: ScoredAssessment.make
        )
        assertInvalidValue(try ScoredAssessment.Harmonized.make(from: ["score": 1]))
    }
    func testCopyWith() throws {
        let sut = try ScoredAssessment.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
        XCTAssertEqual(sut.harmonized.copyWith(answers: [1]).answers, [1])
    }
    func testSave() throws {
        let gad7 = try ScoredAssessment.make(from: dictionary)
        let phq9 = gad7.copyWith(
            identifier: "HKScoredAssessmentTypeIdentifierPHQ9",
            harmonized: gad7.harmonized.copyWith(answers: [0, 1, 2, 3, 0, 1, 2, 3, 4])
        )
        for sample in [gad7, phq9] {
            XCTAssertEqual((try save(sample) as NSError?)?.domain, HKErrorDomain)
        }
        let invalidValues = [
            gad7.copyWith(harmonized: gad7.harmonized.copyWith(answers: [0, 1])),
            gad7.copyWith(harmonized: gad7.harmonized.copyWith(answers: [4, 0, 0, 0, 0, 0, 0])),
            phq9.copyWith(harmonized: phq9.harmonized.copyWith(answers: [4, 0, 0, 0, 0, 0, 0, 0, 0]))
        ]
        for sample in invalidValues {
            assertInvalidValue(try { throw try XCTUnwrap(try save(sample)) }())
        }
        assertInvalidType(try { throw try XCTUnwrap(try save(gad7.copyWith(identifier: "invalid"))) }())
    }

    private func assertAssessment(
        _ sut: ScoredAssessment,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.identifier, "HKScoredAssessmentTypeIdentifierGAD7", file: file, line: line)
        XCTAssertEqual(sut.startTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        assertDevice(sut.device, file: file, line: line)
        assertSourceRevision(sut.sourceRevision, file: file, line: line)
        XCTAssertEqual(sut.harmonized.answers, [0, 1, 2, 3, 0, 1, 2], file: file, line: line)
        XCTAssertEqual(sut.harmonized.score, 9, file: file, line: line)
        XCTAssertEqual(sut.harmonized.risk, 2, file: file, line: line)
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": true], file: file, line: line)
    }
}

// MARK: - Identity
@available(iOS 18.0, watchOS 11.0, *)
extension ScoredAssessmentTests {
    func testCreateFromDictionaryKeepsUUID() throws {
        try assertMakeKeepsUUID(from: dictionary, make: ScoredAssessment.make)
    }
    func testCopyWithKeepsUUID() throws {
        let sut = try ScoredAssessment.make(from: dictionary)
        XCTAssertEqual(sut.copyWith(startTimestamp: 1).uuid, sut.uuid)
    }
}
