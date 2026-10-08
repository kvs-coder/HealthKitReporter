//
//  SourceTests.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

class SourceTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let sut = Source(name: "myApp", bundleIdentifier: "com.my.app")
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            Source.self,
            from: encoded.data(using: .utf8)!
        )
        XCTAssertEqual(decoded.name, "myApp")
        XCTAssertEqual(decoded.bundleIdentifier, "com.my.app")
    }
    func testCreateFromDictionary() throws {
        let dictionary = [
            "name": "myApp",
            "bundleIdentifier": "com.my.app"
        ]
        let sut = try Source.make(from: dictionary)
        XCTAssertEqual(sut.name, "myApp")
        XCTAssertEqual(sut.bundleIdentifier, "com.my.app")
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["name", "bundleIdentifier"],
            in: ["name": "Health", "bundleIdentifier": "com.apple.Health"],
            make: Source.make
        )
    }
    func testCopyWithNoArgumentsKeepsAllFields() throws {
        let sut = Source(name: "Health", bundleIdentifier: "com.apple.Health")
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
    }
    func testCopyWithChangesOnlyGivenField() throws {
        let sut = Source(name: "Health", bundleIdentifier: "com.apple.Health")
        let copy = sut.copyWith(name: "Fitness")
        XCTAssertEqual(copy.name, "Fitness")
        XCTAssertEqual(copy.bundleIdentifier, "com.apple.Health")
    }
}
