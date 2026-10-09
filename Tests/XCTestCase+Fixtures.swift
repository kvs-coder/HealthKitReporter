//
//  XCTestCase+Fixtures.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

/// Set once a save got an answer, so later test classes skip the warm-up
private var healthStoreAnswersWrites = false

extension XCTestCase {
    /**
     Waits until the simulator's health daemon answers a save. After a cold boot on a slow machine
     (CI) it answers reads at once but drops writes for a minute or two, so a write is retried
     every 10 seconds, for up to 5 minutes, once per test run. Without the HealthKit entitlement
     the save fails, so nothing is written.
     */
    static func warmUpHealthStore() {
        guard !healthStoreAnswersWrites else {
            return
        }
        let probe = Quantity(
            identifier: "HKQuantityTypeIdentifierStepCount",
            startTimestamp: 1626884800,
            endTimestamp: 1626884860,
            device: nil,
            sourceRevision: SourceRevision(
                source: Source(name: "warm-up", bundleIdentifier: "com.kvs.hkreporter"),
                version: nil,
                productType: nil,
                systemVersion: "1.0.0",
                operatingSystem: SourceRevision.OperatingSystem(
                    majorVersion: 1,
                    minorVersion: 0,
                    patchVersion: 0
                )
            ),
            harmonized: Quantity.Harmonized(value: 1, unit: "count", metadata: nil)
        )
        let deadline = Date().addingTimeInterval(300)
        while Date() < deadline {
            let answered = DispatchSemaphore(value: 0)
            HealthKitReporter().writer.save(sample: probe) { _, _, _ in
                answered.signal()
            }
            if answered.wait(timeout: .now() + 10) == .success {
                healthStoreAnswersWrites = true
                return
            }
        }
    }
    var startTimestamp: Double {
        return 1626884800
    }
    var storedUUID: String {
        return "8B1F9C1E-4E0A-4C38-9D57-1B2F4A6C7D10"
    }
    /// `make(from:)` keeps the dictionary's uuid, and creates one when the dictionary carries none
    func assertMakeKeepsUUID<T: Sample>(
        from dictionary: [String: Any],
        make: ([String: Any]) throws -> T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        var stored = dictionary
        stored["uuid"] = storedUUID
        XCTAssertEqual(try make(stored).uuid, storedUUID, file: file, line: line)
        XCTAssertNotNil(UUID(uuidString: try make(dictionary).uuid), file: file, line: line)
    }
    var endTimestamp: Double {
        return 1626884860
    }
    var device: Device {
        return Device(
            name: "Guy's iPhone",
            manufacturer: "Guy",
            model: "6.1.1",
            hardwareVersion: "some_0",
            firmwareVersion: "some_1",
            softwareVersion: "some_2",
            localIdentifier: "some_3",
            udiDeviceIdentifier: "some_4"
        )
    }
    var sourceRevision: SourceRevision {
        return SourceRevision(
            source: Source(
                name: "mySource",
                bundleIdentifier: "com.kvs.hkreporter"
            ),
            version: "1.0.0",
            productType: "iPhone13,3",
            systemVersion: "1.0.0.0",
            operatingSystem: SourceRevision.OperatingSystem(
                majorVersion: 1,
                minorVersion: 2,
                patchVersion: 3
            )
        )
    }
    var deviceDictionary: [String: Any] {
        return [
            "name": "Guy's iPhone",
            "manufacturer": "Guy",
            "model": "6.1.1",
            "hardwareVersion": "some_0",
            "firmwareVersion": "some_1",
            "softwareVersion": "some_2",
            "localIdentifier": "some_3",
            "udiDeviceIdentifier": "some_4"
        ]
    }
    var sourceRevisionDictionary: [String: Any] {
        return [
            "source": [
                "name": "mySource",
                "bundleIdentifier": "com.kvs.hkreporter"
            ],
            "version": "1.0.0",
            "productType": "iPhone13,3",
            "systemVersion": "1.0.0.0",
            "operatingSystem": [
                "majorVersion": 1,
                "minorVersion": 2,
                "patchVersion": 3
            ]
        ]
    }
    /// Encodes the value into a JSON dictionary, dropping the generated `uuid` and the `excluding` keys
    func json(
        _ value: Encodable,
        excluding keys: [String] = []
    ) throws -> NSDictionary {
        let data = try XCTUnwrap(value.encoded().data(using: .utf8))
        var dictionary = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        for key in keys + ["uuid"] {
            dictionary.removeValue(forKey: key)
        }
        return dictionary as NSDictionary
    }
    var startDate: Date {
        return Date(timeIntervalSince1970: startTimestamp)
    }
    var endDate: Date {
        return Date(timeIntervalSince1970: endTimestamp)
    }
    /// Runs HK samples through the anchored query update handler: the public HK → payload path of the reader
    /// Decodes the payload from a dictionary the way the Flutter plugin sends it over the channel
    func decode<T: Decodable>(
        _ type: T.Type,
        from dictionary: [String: Any]
    ) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try JSONDecoder().decode(type, from: data)
    }
    func assertDevice(
        _ device: Device?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(device?.name, "Guy's iPhone", file: file, line: line)
        XCTAssertEqual(device?.manufacturer, "Guy", file: file, line: line)
        XCTAssertEqual(device?.model, "6.1.1", file: file, line: line)
        XCTAssertEqual(device?.hardwareVersion, "some_0", file: file, line: line)
        XCTAssertEqual(device?.firmwareVersion, "some_1", file: file, line: line)
        XCTAssertEqual(device?.softwareVersion, "some_2", file: file, line: line)
        XCTAssertEqual(device?.localIdentifier, "some_3", file: file, line: line)
        XCTAssertEqual(device?.udiDeviceIdentifier, "some_4", file: file, line: line)
    }
    func assertSourceRevision(
        _ sourceRevision: SourceRevision,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sourceRevision.source.name, "mySource", file: file, line: line)
        XCTAssertEqual(sourceRevision.source.bundleIdentifier, "com.kvs.hkreporter", file: file, line: line)
        XCTAssertEqual(sourceRevision.version, "1.0.0", file: file, line: line)
        XCTAssertEqual(sourceRevision.productType, "iPhone13,3", file: file, line: line)
        XCTAssertEqual(sourceRevision.systemVersion, "1.0.0.0", file: file, line: line)
        XCTAssertEqual(sourceRevision.operatingSystem.majorVersion, 1, file: file, line: line)
        XCTAssertEqual(sourceRevision.operatingSystem.minorVersion, 2, file: file, line: line)
        XCTAssertEqual(sourceRevision.operatingSystem.patchVersion, 3, file: file, line: line)
    }
    func assertInvalidValue<T>(
        _ expression: @autoclosure () throws -> T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try expression(), file: file, line: line) { error in
            guard case HealthKitError.invalidValue = error else {
                XCTFail("Expected invalidValue, got \(error)", file: file, line: line)
                return
            }
        }
    }
    func assertInvalidType<T>(
        _ expression: @autoclosure () throws -> T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try expression(), file: file, line: line) { error in
            guard case HealthKitError.invalidType = error else {
                XCTFail("Expected invalidType, got \(error)", file: file, line: line)
                return
            }
        }
    }
    /// Removes each key in turn and asserts that `make` throws **HealthKitError.invalidValue**
    func assertEachKeyIsRequired<T>(
        _ keys: [String],
        in dictionary: [String: Any],
        make: ([String: Any]) throws -> T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for key in keys {
            var incomplete = dictionary
            let removed = incomplete.removeValue(forKey: key)
            XCTAssertNotNil(removed, "Missing key: \(key)", file: file, line: line)
            assertInvalidValue(try make(incomplete), file: file, line: line)
        }
    }
    /// Removes each key in turn and asserts that decoding throws a **DecodingError**
    func assertEachKeyIsRequired<T: Decodable>(
        _ keys: [String],
        in dictionary: [String: Any],
        decoding type: T.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for key in keys {
            var incomplete = dictionary
            let removed = incomplete.removeValue(forKey: key)
            XCTAssertNotNil(removed, "Missing key: \(key)", file: file, line: line)
            XCTAssertThrowsError(try decode(type, from: incomplete), file: file, line: line) { error in
                XCTAssertTrue(error is DecodingError, "Unexpected error: \(error)", file: file, line: line)
            }
        }
    }
}
// MARK: - Writing
extension XCTestCase {
    /// Saves the sample through the public writer and returns the reported error
    func save(_ sample: Sample) throws -> Error? {
        let expectation = expectation(description: "completion")
        var saveError: Error?
        HealthKitReporter().writer.save(sample: sample) { _, _, error in
            saveError = error
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
        return saveError
    }
}
