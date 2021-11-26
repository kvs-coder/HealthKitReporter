//
//  CategoryTests.swift
//  
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

class CategoryTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let startDate = Date(timeIntervalSince1970: 1626884800)
        let endDate = startDate.addingTimeInterval(60)
        let sut = Category(
            identifier: CategoryType.sleepAnalysis.identifier!,
            startTimestamp: startDate.timeIntervalSince1970,
            endTimestamp: endDate.timeIntervalSince1970,
            device: Device(
                name: "Guy's iPhone",
                manufacturer: "Guy",
                model: "6.1.1",
                hardwareVersion: "some_0",
                firmwareVersion: "some_1",
                softwareVersion: "some_2",
                localIdentifier: "some_3",
                udiDeviceIdentifier: "some_4"
            ),
            sourceRevision: SourceRevision(
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
            ),
            harmonized: Category.Harmonized(
                value: 1,
                name: "HKCategoryValueSleepAnalysis",
                detail: "Asleep",
                metadata: ["HKWasUserEntered": "1"]
            )
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            Category.self,
            from: encoded.data(using: .utf8)!
        )
        XCTAssertEqual(decoded.identifier, "HKCategoryTypeIdentifierSleepAnalysis")
        XCTAssertEqual(decoded.startTimestamp, 1626884800)
        XCTAssertEqual(decoded.endTimestamp, 1626884800 + 60)
        XCTAssertEqual(decoded.device?.name, "Guy's iPhone")
        XCTAssertEqual(decoded.device?.manufacturer, "Guy")
        XCTAssertEqual(decoded.device?.model, "6.1.1")
        XCTAssertEqual(decoded.device?.hardwareVersion, "some_0")
        XCTAssertEqual(decoded.device?.firmwareVersion, "some_1")
        XCTAssertEqual(decoded.device?.softwareVersion, "some_2")
        XCTAssertEqual(decoded.device?.localIdentifier, "some_3")
        XCTAssertEqual(decoded.device?.udiDeviceIdentifier, "some_4")
        XCTAssertEqual(decoded.sourceRevision.source.name, "mySource")
        XCTAssertEqual(decoded.sourceRevision.source.bundleIdentifier, "com.kvs.hkreporter")
        XCTAssertEqual(decoded.sourceRevision.version, "1.0.0")
        XCTAssertEqual(decoded.sourceRevision.productType, "CocoaPod")
        XCTAssertEqual(decoded.sourceRevision.systemVersion, "1.0.0.0")
        XCTAssertEqual(decoded.sourceRevision.operatingSystem.majorVersion, 1)
        XCTAssertEqual(decoded.sourceRevision.operatingSystem.minorVersion, 1)
        XCTAssertEqual(decoded.sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(decoded.harmonized.value, 1)
        XCTAssertEqual(decoded.harmonized.name, "HKCategoryValueSleepAnalysis")
        XCTAssertEqual(decoded.harmonized.detail, "Asleep")
        XCTAssertEqual(decoded.harmonized.metadata, ["HKWasUserEntered": "1"])
    }
    func testCreateFromDictionary() throws {
        let dictionary: [String: Any] = [
            "identifier": "HKCategoryTypeIdentifierSleepAnalysis",
            "startTimestamp": 1630618680,
            "endTimestamp": 1630697880,
            "device": [
                "name": nil,
                "manufacturer": nil,
                "model": nil,
                "hardwareVersion": nil,
                "firmwareVersion": nil,
                "softwareVersion": nil,
                "localIdentifier": nil,
                "udiDeviceIdentifier": nil
            ],
            "sourceRevision": [
                "source": [
                    "name": "Health",
                    "bundleIdentifier": "com.apple.Health"
                ],
                "version": "14.5",
                "productType": "iPhone13,3",
                "systemVersion": "14.5.0",
                "operatingSystem": [
                    "majorVersion": 14,
                    "minorVersion": 5,
                    "patchVersion": 0
                ]
            ],
            "harmonized": [
                "value": 1,
                "name": "HKCategoryValueSleepAnalysis",
                "detail": "Asleep",
                "metadata": [
                    "HKWasUserEntered": "1"
                ]
            ]
        ]
        let epsilon = 1.0
        let sut = try Category.make(from: dictionary)
        XCTAssertEqual(sut.identifier, "HKCategoryTypeIdentifierSleepAnalysis")
        XCTAssertEqual(sut.startTimestamp, 1630618680, accuracy: epsilon)
        XCTAssertEqual(sut.endTimestamp, 1630697880, accuracy: epsilon)
        XCTAssertNil(sut.device?.name)
        XCTAssertNil(sut.device?.manufacturer)
        XCTAssertNil(sut.device?.model)
        XCTAssertNil(sut.device?.hardwareVersion)
        XCTAssertNil(sut.device?.firmwareVersion)
        XCTAssertNil(sut.device?.softwareVersion)
        XCTAssertNil(sut.device?.localIdentifier)
        XCTAssertNil(sut.device?.udiDeviceIdentifier)
        XCTAssertEqual(sut.sourceRevision.source.name, "Health")
        XCTAssertEqual(sut.sourceRevision.source.bundleIdentifier, "com.apple.Health")
        XCTAssertEqual(sut.sourceRevision.version, "14.5")
        XCTAssertEqual(sut.sourceRevision.productType, "iPhone13,3")
        XCTAssertEqual(sut.sourceRevision.systemVersion, "14.5.0")
        XCTAssertEqual(sut.sourceRevision.operatingSystem.majorVersion, 14)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.minorVersion, 5)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.patchVersion, 0)
        XCTAssertEqual(sut.harmonized.value, 1)
        XCTAssertEqual(sut.harmonized.name, "HKCategoryValueSleepAnalysis")
        XCTAssertEqual(sut.harmonized.detail, "Asleep")
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": "1"])
    }
}
