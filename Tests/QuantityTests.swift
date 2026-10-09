//
//  QuantityTests.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKit
import HealthKitReporter

class QuantityTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let startDate = Date(timeIntervalSince1970: 1626884800)
        let endDate = startDate.addingTimeInterval(60)
        let sut = Quantity(
            identifier: QuantityType.stepCount.identifier!,
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
            harmonized: Quantity.Harmonized(
                value: 123.0,
                unit: "count",
                metadata: ["you": "saved it"]
            )
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            Quantity.self,
            from: encoded.data(using: .utf8)!
        )
        XCTAssertEqual(decoded.identifier, "HKQuantityTypeIdentifierStepCount")
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
        XCTAssertEqual(decoded.harmonized.value, 123)
        XCTAssertEqual(decoded.harmonized.unit, "count")
        XCTAssertEqual(decoded.harmonized.metadata, ["you": "saved it"])
    }
    func testCreateFromDictionary() throws {
        let dictionary: [String: Any] = [
            "identifier": "HKQuantityTypeIdentifierStepCount",
            "startTimestamp": 1624906509.076,
            "endTimestamp": 1624906569.076,
            "device": [
                "name": "FlutterTracker",
                "manufacturer": "kvs",
                "model": "T-800",
                "hardwareVersion": "3",
                "firmwareVersion": "3.0",
                "softwareVersion": "1.1.1",
                "localIdentifier": "kvs.sample.app",
                "udiDeviceIdentifier": "444-888-555"
            ],
            "sourceRevision": [
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
            ],
            "harmonized": [
                "value": 100,
                "unit": "count",
                "metadata": ["some": "meta"]
            ]
        ]
        let epsilon = 1.0
        let sut = try Quantity.make(from: dictionary)
        XCTAssertEqual(sut.identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(sut.startTimestamp, 1624906509, accuracy: epsilon)
        XCTAssertEqual(sut.endTimestamp, 1624906569, accuracy: epsilon)
        XCTAssertEqual(sut.device?.name, "FlutterTracker")
        XCTAssertEqual(sut.device?.manufacturer, "kvs")
        XCTAssertEqual(sut.device?.model, "T-800")
        XCTAssertEqual(sut.device?.hardwareVersion, "3")
        XCTAssertEqual(sut.device?.firmwareVersion, "3.0")
        XCTAssertEqual(sut.device?.softwareVersion, "1.1.1")
        XCTAssertEqual(sut.device?.localIdentifier, "kvs.sample.app")
        XCTAssertEqual(sut.device?.udiDeviceIdentifier, "444-888-555")
        XCTAssertEqual(sut.sourceRevision.source.name, "health_kit_reporter_example")
        XCTAssertEqual(sut.sourceRevision.source.bundleIdentifier, "com.kvs.healthKitReporterExample")
        XCTAssertEqual(sut.sourceRevision.version, "1")
        XCTAssertEqual(sut.sourceRevision.productType, "iPhone13,3")
        XCTAssertEqual(sut.sourceRevision.systemVersion, "14.5.0")
        XCTAssertEqual(sut.sourceRevision.operatingSystem.majorVersion, 14)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.minorVersion, 5)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.patchVersion, 0)
        XCTAssertEqual(sut.harmonized.value, 100)
        XCTAssertEqual(sut.harmonized.unit, "count")
        XCTAssertEqual(sut.harmonized.metadata, ["some": "meta"])
    }
    private var harmonizedDictionary: [String: Any] {
        return [
            "value": 1000,
            "unit": "m",
            "metadata": [
                "you": "saved it"
            ]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKQuantityTypeIdentifierDistanceWalkingRunning",
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
            make: Quantity.make
        )
        assertEachKeyIsRequired(
            ["value", "unit"],
            in: harmonizedDictionary,
            make: Quantity.Harmonized.make
        )
    }
    func testCreateFromDictionaryWithoutDevice() throws {
        var dictionary = dictionary
        dictionary.removeValue(forKey: "device")
        let sut = try Quantity.make(from: dictionary)
        XCTAssertNil(sut.device)
    }
    func testCopyWithNoArgumentsKeepsAllFields() throws {
        let sut = try Quantity.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
    }
    func testCopyWithChangesOnlyGivenField() throws {
        let sut = try Quantity.make(from: dictionary)
        let copy = sut.copyWith(identifier: "HKQuantityTypeIdentifierDistanceCycling")
        XCTAssertEqual(copy.identifier, "HKQuantityTypeIdentifierDistanceCycling")
        XCTAssertEqual(
            try json(copy, excluding: ["identifier"]),
            try json(sut, excluding: ["identifier"])
        )
        let harmonized = sut.harmonized.copyWith(value: 5)
        XCTAssertEqual(harmonized.value, 5, accuracy: 0.001)
        XCTAssertEqual(
            try json(harmonized, excluding: ["value"]),
            try json(sut.harmonized, excluding: ["value"])
        )
    }
    func testCollectRejectsNonDictionaryElements() throws {
        assertInvalidValue(try Quantity.collect(from: [dictionary, "invalid"]))
        assertInvalidValue(try Quantity.collect(from: [dictionary, 1]))
        let sut = try Quantity.collect(from: [dictionary, dictionary])
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[0].identifier, "HKQuantityTypeIdentifierDistanceWalkingRunning")
        XCTAssertEqual(sut[1].identifier, "HKQuantityTypeIdentifierDistanceWalkingRunning")
    }
    func testCollectThrowsOnInvalidDictionary() throws {
        assertInvalidValue(try Quantity.collect(from: [dictionary, ["identifier": "invalid"]]))
    }
    func testConvertedToSameUnitReturnsSelf() throws {
        let sut = try Quantity.make(from: dictionary)
        let converted = try sut.converted(to: "m")
        XCTAssertEqual(converted.uuid, sut.uuid)
        XCTAssertEqual(try json(converted), try json(sut))
    }
    func testConvertedToOtherUnit() throws {
        let sut = try Quantity.make(from: dictionary)
        let converted = try sut.converted(to: "km")
        XCTAssertEqual(converted.identifier, "HKQuantityTypeIdentifierDistanceWalkingRunning")
        XCTAssertEqual(converted.startTimestamp, 1626884800, accuracy: 0.001)
        XCTAssertEqual(converted.endTimestamp, 1626884860, accuracy: 0.001)
        assertDevice(converted.device)
        XCTAssertEqual(converted.harmonized.value, 1, accuracy: 0.001)
        XCTAssertEqual(converted.harmonized.unit, "km")
        XCTAssertEqual(converted.harmonized.metadata, ["you": "saved it"])
        XCTAssertEqual(converted.uuid, sut.uuid)
        XCTAssertEqual(try json(converted.sourceRevision), try json(sut.sourceRevision))
    }
    func testConvertedToMalformedOrIncompatibleUnitThrows() throws {
        let sut = try Quantity.make(from: dictionary)
        assertInvalidValue(try sut.converted(to: "kg"))
        assertInvalidValue(try sut.converted(to: "notAUnit"))
    }
    func testConvertedWithInvalidIdentifierThrows() throws {
        let sut = try Quantity.make(from: dictionary).copyWith(identifier: "invalid")
        assertInvalidType(try sut.converted(to: "km"))
    }
}
// MARK: - Factory
extension QuantityTests {
    /// Units covering every **QuantityType** dimension; the first compatible one is used to build a sample
    private var candidateUnits: [HKUnit] {
        return [
            "count", "m", "kg", "kcal", "s", "%", "count/min", "degC", "mmHg", "dBASPL", "ml/kg*min",
            "L", "L/min", "mg/dL", "IU", "S", "m/s", "W", "mL", "g", "kcal/hr·kg", "appleEffortScore"
        ].map { HKUnit(from: $0) }
    }

    /// Insulin delivery is the only type HealthKit requires metadata for
    private func metadata(for type: QuantityType) -> [String: Any]? {
        guard type == .insulinDelivery else {
            return nil
        }
        return [HKMetadataKeyInsulinDeliveryReason: HKInsulinDeliveryReason.basal.rawValue]
    }
}

// MARK: - Identity
extension QuantityTests {
    func testCreateFromDictionaryKeepsUUID() throws {
        try assertMakeKeepsUUID(from: dictionary, make: Quantity.make)
    }
    func testCopyWithKeepsUUID() throws {
        let sut = try Quantity.make(from: dictionary)
        XCTAssertEqual(sut.copyWith(startTimestamp: 1).uuid, sut.uuid)
        XCTAssertEqual(sut.copyWith(uuid: storedUUID).uuid, storedUUID)
    }
}
