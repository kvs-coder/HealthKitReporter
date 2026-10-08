//
//  CharacteristicTests.swift
//  
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

class CharacteristicTests: XCTestCase {
    private var dictionary: [String: Any] {
        return [
            "biologicalSex": "male",
            "birthday": "1990-01-01T00:00:00.000Z",
            "bloodType": "A+",
            "fitzpatrickSkinType": "III",
            "wheelchairUse": "no",
            "activityMoveMode": "activeEnergy"
        ]
    }

    func testCreateFromDictionary() throws {
        let sut = try decode(Characteristic.self, from: dictionary)
        assertCharacteristic(sut)
    }
    func testCreateThenEncodeThenDecode() throws {
        let sut = try decode(Characteristic.self, from: dictionary)
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            Characteristic.self,
            from: try XCTUnwrap(encoded.data(using: .utf8))
        )
        assertCharacteristic(decoded)
    }
    func testCreateFromEmptyDictionary() throws {
        let sut = try decode(Characteristic.self, from: [:])
        XCTAssertNil(sut.biologicalSex)
        XCTAssertNil(sut.birthday)
        XCTAssertNil(sut.bloodType)
        XCTAssertNil(sut.fitzpatrickSkinType)
        XCTAssertNil(sut.wheelchairUse)
        XCTAssertNil(sut.activityMoveMode)
    }
    func testCreateFromInvalidDictionary() throws {
        XCTAssertThrowsError(
            try decode(Characteristic.self, from: ["biologicalSex": 1])
        ) { error in
            XCTAssertTrue(error is DecodingError, "Unexpected error: \(error)")
        }
    }

    private func assertCharacteristic(
        _ sut: Characteristic,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.biologicalSex, "male", file: file, line: line)
        XCTAssertEqual(sut.birthday, "1990-01-01T00:00:00.000Z", file: file, line: line)
        XCTAssertEqual(sut.bloodType, "A+", file: file, line: line)
        XCTAssertEqual(sut.fitzpatrickSkinType, "III", file: file, line: line)
        XCTAssertEqual(sut.wheelchairUse, "no", file: file, line: line)
        XCTAssertEqual(sut.activityMoveMode, "activeEnergy", file: file, line: line)
    }
}
