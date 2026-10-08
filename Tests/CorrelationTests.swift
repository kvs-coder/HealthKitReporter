//
//  CorrelationTests.swift
//  
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKit
import HealthKitReporter

class CorrelationTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let startDate = Date(timeIntervalSince1970: 1626884800)
        let endDate = startDate.addingTimeInterval(60)
        let device = Device(
            name: "Guy's iPhone",
            manufacturer: "Guy",
            model: "6.1.1",
            hardwareVersion: "some_0",
            firmwareVersion: "some_1",
            softwareVersion: "some_2",
            localIdentifier: "some_3",
            udiDeviceIdentifier: "some_4"
        )
        let source = Source(
            name: "mySource",
            bundleIdentifier: "com.kvs.hkreporter"
        )
        let operatingSystem = SourceRevision.OperatingSystem(
            majorVersion: 1,
            minorVersion: 1,
            patchVersion: 1
        )
        let sourceRevision = SourceRevision(
            source: source,
            version: "1.0.0",
            productType: "CocoaPod",
            systemVersion: "1.0.0.0",
            operatingSystem: operatingSystem
        )
        let sys = Quantity(
            identifier: QuantityType.bloodPressureSystolic.identifier!,
            startTimestamp: startDate.timeIntervalSince1970,
            endTimestamp: endDate.timeIntervalSince1970,
            device: device,
            sourceRevision: sourceRevision,
            harmonized: Quantity.Harmonized(
                value: 123.0,
                unit: "mmHg",
                metadata: ["you": "saved it"]
            )
        )
        let dias = Quantity(
            identifier: QuantityType.bloodPressureDiastolic.identifier!,
            startTimestamp: startDate.timeIntervalSince1970,
            endTimestamp: endDate.timeIntervalSince1970,
            device: device,
            sourceRevision: sourceRevision,
            harmonized: Quantity.Harmonized(
                value: 83.0,
                unit: "mmHg",
                metadata: ["you": "saved it"]
            )
        )
        let sut = Correlation(
            identifier: CorrelationType.bloodPressure.identifier!,
            startTimestamp: startDate.timeIntervalSince1970,
            endTimestamp: endDate.timeIntervalSince1970,
            device: device, sourceRevision: sourceRevision,
            harmonized: Correlation.Harmonized(
                quantitySamples: [sys, dias],
                categorySamples: [],
                metadata: ["you": "saved it"]
            )
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            Correlation.self,
            from: encoded.data(using: .utf8)!
        )
        XCTAssertEqual(decoded.identifier, "HKCorrelationTypeIdentifierBloodPressure")
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
        XCTAssertEqual(decoded.harmonized.quantitySamples.count, 2)
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].identifier, "HKQuantityTypeIdentifierBloodPressureSystolic")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].startTimestamp, 1626884800)
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].endTimestamp, 1626884800 + 60)
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].device?.name, "Guy's iPhone")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].device?.manufacturer, "Guy")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].device?.model, "6.1.1")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].device?.hardwareVersion, "some_0")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].device?.firmwareVersion, "some_1")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].device?.softwareVersion, "some_2")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].device?.localIdentifier, "some_3")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].device?.udiDeviceIdentifier, "some_4")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].sourceRevision.source.name, "mySource")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].sourceRevision.source.bundleIdentifier, "com.kvs.hkreporter")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].sourceRevision.version, "1.0.0")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].sourceRevision.productType, "CocoaPod")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].sourceRevision.systemVersion, "1.0.0.0")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].sourceRevision.operatingSystem.majorVersion, 1)
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].sourceRevision.operatingSystem.minorVersion, 1)
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].harmonized.value, 123)
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].harmonized.unit, "mmHg")
        XCTAssertEqual(decoded.harmonized.quantitySamples[0].harmonized.metadata, ["you": "saved it"])
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].identifier, "HKQuantityTypeIdentifierBloodPressureDiastolic")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].startTimestamp, 1626884800)
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].endTimestamp, 1626884800 + 60)
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].device?.name, "Guy's iPhone")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].device?.manufacturer, "Guy")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].device?.model, "6.1.1")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].device?.hardwareVersion, "some_0")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].device?.firmwareVersion, "some_1")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].device?.softwareVersion, "some_2")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].device?.localIdentifier, "some_3")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].device?.udiDeviceIdentifier, "some_4")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].sourceRevision.source.name, "mySource")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].sourceRevision.source.bundleIdentifier, "com.kvs.hkreporter")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].sourceRevision.version, "1.0.0")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].sourceRevision.productType, "CocoaPod")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].sourceRevision.systemVersion, "1.0.0.0")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].sourceRevision.operatingSystem.majorVersion, 1)
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].sourceRevision.operatingSystem.minorVersion, 1)
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].harmonized.value, 83)
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].harmonized.unit, "mmHg")
        XCTAssertEqual(decoded.harmonized.quantitySamples[1].harmonized.metadata, ["you": "saved it"])
        XCTAssertEqual(decoded.harmonized.categorySamples.count, 0)
        XCTAssertEqual(decoded.harmonized.metadata, ["you": "saved it"])
    }
    func testCreateFromDictionary() throws {
        let dictionary: [String: Any] = [
            "device" : [
              "manufacturer" : "Guy",
              "softwareVersion" : "some_2",
              "model" : "6.1.1",
              "localIdentifier" : "some_3",
              "firmwareVersion" : "some_1",
              "udiDeviceIdentifier" : "some_4",
              "name" : "Guy's iPhone",
              "hardwareVersion" : "some_0"
            ],
            "sourceRevision" : [
              "productType" : "CocoaPod",
              "systemVersion" : "1.0.0.0",
              "source" : [
                "name" : "mySource",
                "bundleIdentifier" : "com.kvs.hkreporter"
              ],
              "operatingSystem" : [
                "majorVersion" : 1,
                "minorVersion" : 1,
                "patchVersion" : 1
              ],
              "version" : "1.0.0"
            ],
            "uuid" : "BA0ADD39-638C-4FF8-AF48-0FC88CDCC48A",
            "identifier" : "HKCorrelationTypeIdentifierBloodPressure",
            "startTimestamp" : 1653657145.998812,
            "endTimestamp" : 1653657205.998812,
            "harmonized" : [
              "metadata" : [
                "you" : "saved it"
              ],
              "categorySamples" : [

              ],
              "quantitySamples" : [
                [
                  "device" : [
                    "manufacturer" : "Guy",
                    "softwareVersion" : "some_2",
                    "model" : "6.1.1",
                    "localIdentifier" : "some_3",
                    "firmwareVersion" : "some_1",
                    "udiDeviceIdentifier" : "some_4",
                    "name" : "Guy's iPhone",
                    "hardwareVersion" : "some_0"
                  ],
                  "sourceRevision" : [
                    "productType" : "CocoaPod",
                    "systemVersion" : "1.0.0.0",
                    "source" : [
                      "name" : "mySource",
                      "bundleIdentifier" : "com.kvs.hkreporter"
                    ],
                    "operatingSystem" : [
                      "majorVersion" : 1,
                      "minorVersion" : 1,
                      "patchVersion" : 1
                    ],
                    "version" : "1.0.0"
                  ],
                  "uuid" : "52DC2FFB-D361-4CDC-9450-29EFEBD1BD94",
                  "identifier" : "HKQuantityTypeIdentifierBloodPressureSystolic",
                  "startTimestamp" : 1653657145.998812,
                  "endTimestamp" : 1653657205.998812,
                  "harmonized" : [
                    "value" : 123,
                    "metadata" : [
                      "you" : "saved it"
                    ],
                    "unit" : "mmHg"
                  ]
                ],
                [
                  "device" : [
                    "manufacturer" : "Guy",
                    "softwareVersion" : "some_2",
                    "model" : "6.1.1",
                    "localIdentifier" : "some_3",
                    "firmwareVersion" : "some_1",
                    "udiDeviceIdentifier" : "some_4",
                    "name" : "Guy's iPhone",
                    "hardwareVersion" : "some_0"
                  ],
                  "sourceRevision" : [
                    "productType" : "CocoaPod",
                    "systemVersion" : "1.0.0.0",
                    "source" : [
                      "name" : "mySource",
                      "bundleIdentifier" : "com.kvs.hkreporter"
                    ],
                    "operatingSystem" : [
                      "majorVersion" : 1,
                      "minorVersion" : 1,
                      "patchVersion" : 1
                    ],
                    "version" : "1.0.0"
                  ],
                  "uuid" : "3850F06E-383B-476A-BFCC-4A6DF979CFAE",
                  "identifier" : "HKQuantityTypeIdentifierBloodPressureDiastolic",
                  "startTimestamp" : 1653657145.998812,
                  "endTimestamp" : 1653657205.998812,
                  "harmonized" : [
                    "value" : 83,
                    "metadata" : [
                      "you" : "saved it"
                    ],
                    "unit" : "mmHg"
                  ]
                ]
              ]
            ]
          ]
        let epsilon = 1.0
        let sut = try Correlation.make(from: dictionary)
        XCTAssertEqual(sut.identifier, "HKCorrelationTypeIdentifierBloodPressure")
        XCTAssertEqual(sut.startTimestamp, 1653657145.998812, accuracy: epsilon)
        XCTAssertEqual(sut.endTimestamp, 1653657205.998812, accuracy: epsilon)
        XCTAssertEqual(sut.device?.name, "Guy's iPhone")
        XCTAssertEqual(sut.device?.manufacturer, "Guy")
        XCTAssertEqual(sut.device?.model, "6.1.1")
        XCTAssertEqual(sut.device?.hardwareVersion, "some_0")
        XCTAssertEqual(sut.device?.firmwareVersion, "some_1")
        XCTAssertEqual(sut.device?.softwareVersion, "some_2")
        XCTAssertEqual(sut.device?.localIdentifier, "some_3")
        XCTAssertEqual(sut.device?.udiDeviceIdentifier, "some_4")
        XCTAssertEqual(sut.sourceRevision.source.name, "mySource")
        XCTAssertEqual(sut.sourceRevision.source.bundleIdentifier, "com.kvs.hkreporter")
        XCTAssertEqual(sut.sourceRevision.version, "1.0.0")
        XCTAssertEqual(sut.sourceRevision.productType, "CocoaPod")
        XCTAssertEqual(sut.sourceRevision.systemVersion, "1.0.0.0")
        XCTAssertEqual(sut.sourceRevision.operatingSystem.majorVersion, 1)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.minorVersion, 1)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(sut.harmonized.quantitySamples.count, 2)
        XCTAssertEqual(sut.harmonized.quantitySamples[0].identifier, "HKQuantityTypeIdentifierBloodPressureSystolic")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].startTimestamp, 1653657145.998812, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.quantitySamples[0].endTimestamp, 1653657205.998812, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.quantitySamples[0].device?.name, "Guy's iPhone")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].device?.manufacturer, "Guy")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].device?.model, "6.1.1")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].device?.hardwareVersion, "some_0")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].device?.firmwareVersion, "some_1")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].device?.softwareVersion, "some_2")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].device?.localIdentifier, "some_3")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].device?.udiDeviceIdentifier, "some_4")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].sourceRevision.source.name, "mySource")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].sourceRevision.source.bundleIdentifier, "com.kvs.hkreporter")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].sourceRevision.version, "1.0.0")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].sourceRevision.productType, "CocoaPod")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].sourceRevision.systemVersion, "1.0.0.0")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].sourceRevision.operatingSystem.majorVersion, 1)
        XCTAssertEqual(sut.harmonized.quantitySamples[0].sourceRevision.operatingSystem.minorVersion, 1)
        XCTAssertEqual(sut.harmonized.quantitySamples[0].sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(sut.harmonized.quantitySamples[0].harmonized.value, 123)
        XCTAssertEqual(sut.harmonized.quantitySamples[0].harmonized.unit, "mmHg")
        XCTAssertEqual(sut.harmonized.quantitySamples[0].harmonized.metadata, ["you": "saved it"])
        XCTAssertEqual(sut.harmonized.quantitySamples[1].identifier, "HKQuantityTypeIdentifierBloodPressureDiastolic")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].startTimestamp, 1653657145.998812, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.quantitySamples[1].endTimestamp, 1653657205.998812, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.quantitySamples[1].device?.name, "Guy's iPhone")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].device?.manufacturer, "Guy")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].device?.model, "6.1.1")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].device?.hardwareVersion, "some_0")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].device?.firmwareVersion, "some_1")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].device?.softwareVersion, "some_2")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].device?.localIdentifier, "some_3")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].device?.udiDeviceIdentifier, "some_4")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].sourceRevision.source.name, "mySource")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].sourceRevision.source.bundleIdentifier, "com.kvs.hkreporter")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].sourceRevision.version, "1.0.0")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].sourceRevision.productType, "CocoaPod")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].sourceRevision.systemVersion, "1.0.0.0")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].sourceRevision.operatingSystem.majorVersion, 1)
        XCTAssertEqual(sut.harmonized.quantitySamples[1].sourceRevision.operatingSystem.minorVersion, 1)
        XCTAssertEqual(sut.harmonized.quantitySamples[1].sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(sut.harmonized.quantitySamples[1].harmonized.value, 83)
        XCTAssertEqual(sut.harmonized.quantitySamples[1].harmonized.unit, "mmHg")
        XCTAssertEqual(sut.harmonized.quantitySamples[1].harmonized.metadata, ["you": "saved it"])
        XCTAssertEqual(sut.harmonized.categorySamples.count, 0)
        XCTAssertEqual(sut.harmonized.metadata, ["you": "saved it"])
    }
}
// MARK: - Payload
extension CorrelationTests {
    private var harmonizedDictionary: [String: Any] {
        return [
            "quantitySamples": [],
            "categorySamples": [],
            "metadata": [
                "HKWasUserEntered": "1"
            ]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKCorrelationTypeIdentifierBloodPressure",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": harmonizedDictionary
        ]
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: dictionary,
            make: Correlation.make
        )
        assertEachKeyIsRequired(
            ["quantitySamples", "categorySamples"],
            in: harmonizedDictionary,
            make: Correlation.Harmonized.make
        )
    }
    func testCreateFromDictionaryWithoutDevice() throws {
        var dictionary = dictionary
        dictionary.removeValue(forKey: "device")
        let sut = try Correlation.make(from: dictionary)
        XCTAssertNil(sut.device)
        XCTAssertTrue(sut.harmonized.quantitySamples.isEmpty)
        XCTAssertTrue(sut.harmonized.categorySamples.isEmpty)
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": "1"])
    }
    func testCopyWithNoArgumentsKeepsAllFields() throws {
        let sut = try Correlation.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
    }
    func testCopyWithChangesOnlyGivenField() throws {
        let sut = try Correlation.make(from: dictionary)
        let copy = sut.copyWith(identifier: "HKCorrelationTypeIdentifierFood")
        XCTAssertEqual(copy.identifier, "HKCorrelationTypeIdentifierFood")
        XCTAssertEqual(
            try json(copy, excluding: ["identifier"]),
            try json(sut, excluding: ["identifier"])
        )
        let harmonized = sut.harmonized.copyWith(metadata: ["HKWasUserEntered": "0"])
        XCTAssertEqual(harmonized.metadata, ["HKWasUserEntered": "0"])
        XCTAssertEqual(
            try json(harmonized, excluding: ["metadata"]),
            try json(sut.harmonized, excluding: ["metadata"])
        )
    }
}
// MARK: - Factory
extension CorrelationTests {
}

// MARK: - Identity
extension CorrelationTests {
    func testCreateFromDictionaryKeepsUUID() throws {
        try assertMakeKeepsUUID(from: dictionary, make: Correlation.make)
    }
    func testCopyWithKeepsUUID() throws {
        let sut = try Correlation.make(from: dictionary)
        XCTAssertEqual(sut.copyWith(startTimestamp: 1).uuid, sut.uuid)
    }
}
