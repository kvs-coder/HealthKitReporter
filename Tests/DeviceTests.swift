//
//  DeviceTests.swift
//
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

class DeviceTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let sut = Device(
            name: "Guy's iPhone",
            manufacturer: "Guy",
            model: "6.1.1",
            hardwareVersion: "some_0",
            firmwareVersion: "some_1",
            softwareVersion: "some_2",
            localIdentifier: "some_3",
            udiDeviceIdentifier: "some_4"
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            Device.self,
            from: encoded.data(using: .utf8)!
        )
        XCTAssertEqual(decoded.name, "Guy's iPhone")
        XCTAssertEqual(decoded.manufacturer, "Guy")
        XCTAssertEqual(decoded.model, "6.1.1")
        XCTAssertEqual(decoded.hardwareVersion, "some_0")
        XCTAssertEqual(decoded.firmwareVersion, "some_1")
        XCTAssertEqual(decoded.softwareVersion, "some_2")
        XCTAssertEqual(decoded.localIdentifier, "some_3")
        XCTAssertEqual(decoded.udiDeviceIdentifier, "some_4")
    }
    func testCreateFromDictionary() throws {
        let dictionary: [String: Any] = [
            "name": "FlutterTracker",
            "manufacturer": "kvs",
            "model": "T-800",
            "hardwareVersion": "3",
            "firmwareVersion": "3.0",
            "softwareVersion": "1.1.1",
            "localIdentifier": "kvs.sample.app",
            "udiDeviceIdentifier": "444-888-555"
        ]
        let sut = try Device.make(from: dictionary)
        XCTAssertEqual(sut.name, "FlutterTracker")
        XCTAssertEqual(sut.manufacturer, "kvs")
        XCTAssertEqual(sut.model, "T-800")
        XCTAssertEqual(sut.hardwareVersion, "3")
        XCTAssertEqual(sut.firmwareVersion, "3.0")
        XCTAssertEqual(sut.softwareVersion, "1.1.1")
        XCTAssertEqual(sut.localIdentifier, "kvs.sample.app")
        XCTAssertEqual(sut.udiDeviceIdentifier, "444-888-555")
    }
}
