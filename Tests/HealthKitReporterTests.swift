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
        let startDate = Date(timeIntervalSince1970: 1626884)
        let endDate = startDate.addingTimeInterval(60)
        // Create a normal instance of Quantity and encode it to JSON
        let encodedSteps = try Quantity(
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
        ).encoded()
        // Try to create a Quantity out of JSON string from above and check
        // the content
        let jsonData = encodedSteps.data(using: .utf8)!
        let decodedSteps = try JSONDecoder().decode(Quantity.self, from: jsonData)
        XCTAssertEqual(decodedSteps.identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(decodedSteps.startTimestamp, 1626884)
        XCTAssertEqual(decodedSteps.endTimestamp, 1626884 + 60)
        XCTAssertEqual(decodedSteps.device?.name, "Guy's iPhone")
        XCTAssertEqual(decodedSteps.device?.manufacturer, "Guy")
        XCTAssertEqual(decodedSteps.device?.model, "6.1.1")
        XCTAssertEqual(decodedSteps.device?.hardwareVersion, "some_0")
        XCTAssertEqual(decodedSteps.device?.firmwareVersion, "some_1")
        XCTAssertEqual(decodedSteps.device?.softwareVersion, "some_2")
        XCTAssertEqual(decodedSteps.device?.localIdentifier, "some_3")
        XCTAssertEqual(decodedSteps.device?.udiDeviceIdentifier, "some_4")
        XCTAssertEqual(decodedSteps.sourceRevision.source.name, "mySource")
        XCTAssertEqual(decodedSteps.sourceRevision.source.bundleIdentifier, "com.kvs.hkreporter")
        XCTAssertEqual(decodedSteps.sourceRevision.version, "1.0.0")
        XCTAssertEqual(decodedSteps.sourceRevision.productType, "CocoaPod")
        XCTAssertEqual(decodedSteps.sourceRevision.systemVersion, "1.0.0.0")
        XCTAssertEqual(decodedSteps.sourceRevision.operatingSystem.majorVersion, 1)
        XCTAssertEqual(decodedSteps.sourceRevision.operatingSystem.minorVersion, 1)
        XCTAssertEqual(decodedSteps.sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(decodedSteps.harmonized.value, 123)
        XCTAssertEqual(decodedSteps.harmonized.unit, "count")
        XCTAssertEqual(decodedSteps.harmonized.metadata, ["you": "saved it"])
    }
}
