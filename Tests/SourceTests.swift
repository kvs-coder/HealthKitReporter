//
//  SourceTests.swift
//  
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
            "bundleIdentifier": "com.my.app",
        ]
        let sut = try Source.make(from: dictionary)
        XCTAssertEqual(sut.name, "myApp")
        XCTAssertEqual(sut.bundleIdentifier, "com.my.app")
    }
}
