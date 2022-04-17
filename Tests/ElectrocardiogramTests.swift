//
//  ElectrocardiogramTests.swift
//  
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

@available(iOS 14.0, *)
class ElectrocardiogramTests: XCTestCase {
    func testCreateFromDicitionsry() throws {
        let dictionary: [String: Any] = [
            "device" : [
                "softwareVersion" : "8.5.1",
                "manufacturer" : "Apple Inc.",
                "model" : "Watch",
                "name" : "Apple Watch",
                "hardwareVersion" : "Watch6,1"
            ],
            "sourceRevision" : [
                "productType" : "Watch6,1",
                "systemVersion" : "8.5.1",
                "source" : [
                    "name" : "EKG",
                    "bundleIdentifier" : "com.apple.NanoHeartRhythm"
                ],
                "operatingSystem" : [
                    "majorVersion" : 8,
                    "minorVersion" : 5,
                    "patchVersion" : 1
                ],
                "version" : "1.90"
            ],
            "uuid" : "ECB16118-D47F-431C-BAC3-189FE8251FED",
            "numberOfMeasurements" : 15360,
            "identifier" : "HKDataTypeIdentifierElectrocardiogram",
            "endTimestamp" : 1650213492.810982,
            "startTimestamp" : 1650213462.810982,
            "harmonized" : [
                "voltageMeasurements" : [
                    [
                        "harmonized" : [
                            "value" : 3.7860584259033203e-05,
                            "unit" : "V"
                        ],
                        "timeSinceSampleStart" : 0

                    ],
                    [
                        "harmonized" : [
                            "value" : 6.8293251037597656e-05,
                            "unit" : "V"
                        ],
                        "timeSinceSampleStart" : 0.175781250
                    ]
                ],
                "averageHeartRate" : 61,
                "classification" : "Sinus rhytm",
                "samplingFrequencyUnit" : "Hz",
                "count" : 2,
                "averageHeartRateUnit" : "count/min",
                "symptomsStatus" : "na",
                "samplingFrequency" : 512,
                "metadata" : [
                    "HKMetadataKeyAppleECGAlgorithmVersion" : "2",
                    "HKMetadataKeySyncVersion" : "0",
                    "HKMetadataKeySyncIdentifier" : "47D89B1C-FC84-449A-91E1-FB6A2AA737D7"
                ]
            ]
        ]
        let epsilon = 1.0
        let sut = try Electrocardiogram.make(from: dictionary)
        XCTAssertEqual(sut.identifier, "HKDataTypeIdentifierElectrocardiogram")
        XCTAssertEqual(sut.startTimestamp, 1650213462.810982, accuracy: epsilon)
        XCTAssertEqual(sut.endTimestamp, 1650213492.810982, accuracy: epsilon)
        XCTAssertEqual(sut.device?.name, "Apple Watch")
        XCTAssertEqual(sut.device?.manufacturer, "Apple Inc.")
        XCTAssertEqual(sut.device?.model, "Watch")
        XCTAssertEqual(sut.device?.hardwareVersion, "Watch6,1")
        XCTAssertEqual(sut.device?.softwareVersion, "8.5.1")
        XCTAssertEqual(sut.sourceRevision.source.name, "EKG")
        XCTAssertEqual(sut.sourceRevision.source.bundleIdentifier, "com.apple.NanoHeartRhythm")
        XCTAssertEqual(sut.sourceRevision.version, "1.90")
        XCTAssertEqual(sut.sourceRevision.productType, "Watch6,1")
        XCTAssertEqual(sut.sourceRevision.systemVersion, "8.5.1")
        XCTAssertEqual(sut.sourceRevision.operatingSystem.majorVersion, 8)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.minorVersion, 5)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(sut.harmonized.voltageMeasurements[0].harmonized.value, 3.7860584259033203e-05, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.voltageMeasurements[0].harmonized.unit, "V")
        XCTAssertEqual(sut.harmonized.voltageMeasurements[0].timeSinceSampleStart, 0)
        XCTAssertEqual(sut.harmonized.voltageMeasurements[1].harmonized.value, 6.8293251037597656e-05, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.voltageMeasurements[1].harmonized.unit, "V")
        XCTAssertEqual(sut.harmonized.voltageMeasurements[1].timeSinceSampleStart, 0.175781250, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.count, 2)
        XCTAssertEqual(sut.harmonized.voltageMeasurements.count, 2)
        XCTAssertEqual(sut.harmonized.averageHeartRate, 61)
        XCTAssertEqual(sut.harmonized.classification, "Sinus rhytm")
        XCTAssertEqual(sut.harmonized.samplingFrequencyUnit, "Hz")
        XCTAssertEqual(sut.harmonized.averageHeartRateUnit, "count/min")
        XCTAssertEqual(sut.harmonized.symptomsStatus, "na")
        XCTAssertEqual(sut.harmonized.samplingFrequency, 512)
        XCTAssertEqual(
            sut.harmonized.metadata, [
                "HKMetadataKeyAppleECGAlgorithmVersion" : "2",
                "HKMetadataKeySyncVersion" : "0",
                "HKMetadataKeySyncIdentifier" : "47D89B1C-FC84-449A-91E1-FB6A2AA737D7"
            ]
        )
    }
}
