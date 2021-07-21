//
//  HealthKitReporterTests.swift
//  
//
//  Created by Kachalov, Victor on 21.07.21.
//

import XCTest
import HealthKitReporter

class HealthKitReporterTests: XCTestCase {
    let healthKitReporter = try! HealthKitReporter()
    
    func testSteps() throws {
        let now = Date()
        let quantity = Quantity(
            identifier: QuantityType.stepCount.identifier!,
            startTimestamp: now.addingTimeInterval(-60).timeIntervalSince1970,
            endTimestamp: now.timeIntervalSince1970,
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
                metadata: [:]
            )
        )
        let json = try quantity.encoded()
        let data = json.data(using: .utf8)!
        let decodedJson = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(decodedJson?["identifier"] as? String, "HKQuantityTypeIdentifierStepCount")
    }
}
