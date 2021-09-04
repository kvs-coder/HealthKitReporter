//
//  SourceRevisionTests.swift
//  
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

class SourceRevisionTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let sut = SourceRevision(
            source: Source(
                name: "mySource",
                bundleIdentifier: "com.kvs.hkreporter"
            ),
            version: "1.0.0",
            productType: "CocoaPod",
            systemVersion: "1.0.0.0",
            operatingSystem: SourceRevision.OperatingSystem(
                majorVersion: 1,
                minorVersion: 1,
                patchVersion: 1
            )
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            SourceRevision.self,
            from: encoded.data(using: .utf8)!
        )
        XCTAssertEqual(decoded.source.name, "mySource")
        XCTAssertEqual(decoded.source.bundleIdentifier, "com.kvs.hkreporter")
        XCTAssertEqual(decoded.version, "1.0.0")
        XCTAssertEqual(decoded.productType, "CocoaPod")
        XCTAssertEqual(decoded.systemVersion, "1.0.0.0")
        XCTAssertEqual(decoded.operatingSystem.majorVersion, 1)
        XCTAssertEqual(decoded.operatingSystem.minorVersion, 1)
        XCTAssertEqual(decoded.operatingSystem.patchVersion, 1)
    }
    func testCreateFromDictionary() throws {
        let dictionary: [String: Any] = [
            "source": [
                "name": "health_kit_reporter_example",
                "bundleIdentifier": "com.kvs.healthKitReporterExample"
            ],
            "version": "1",
            "productType": "iPhone13,3",
            "systemVersion": "14.5.0",
            "operatingSystem": [
                "majorVersion": 14,
                "minorVersion": 5,
                "patchVersion": 0
            ]
        ]
        let sut = try SourceRevision.make(from: dictionary)
        XCTAssertEqual(sut.source.name, "health_kit_reporter_example")
        XCTAssertEqual(sut.source.bundleIdentifier, "com.kvs.healthKitReporterExample")
        XCTAssertEqual(sut.version, "1")
        XCTAssertEqual(sut.productType, "iPhone13,3")
        XCTAssertEqual(sut.systemVersion, "14.5.0")
        XCTAssertEqual(sut.operatingSystem.majorVersion, 14)
        XCTAssertEqual(sut.operatingSystem.minorVersion, 5)
        XCTAssertEqual(sut.operatingSystem.patchVersion, 0)
    }
}
