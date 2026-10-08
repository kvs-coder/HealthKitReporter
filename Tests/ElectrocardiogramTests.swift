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
    func testCreateFromDicitionary() throws {
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
            "numberOfMeasurements" : 2,
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
        XCTAssertEqual(sut.numberOfMeasurements, 2)
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
    func testCreateFromDicitionaryWithNoVoltageMeasurements() throws {
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
        XCTAssertEqual(sut.harmonized.voltageMeasurements.count, 0)
        XCTAssertEqual(sut.harmonized.count, 2)
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
    private var voltageMeasurementDictionary: [String: Any] {
        return [
            "harmonized": [
                "value": 0.0001,
                "unit": "V"
            ],
            "timeSinceSampleStart": 0.5
        ]
    }
    private var harmonizedDictionary: [String: Any] {
        return [
            "averageHeartRate": 61,
            "averageHeartRateUnit": "count/min",
            "samplingFrequency": 512,
            "samplingFrequencyUnit": "Hz",
            "classification": "sinusRhythm",
            "symptomsStatus": "none",
            "count": 1,
            "voltageMeasurements": [voltageMeasurementDictionary]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKDataTypeIdentifierElectrocardiogram",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "numberOfMeasurements": 1,
            "harmonized": harmonizedDictionary
        ]
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            [
                "identifier",
                "startTimestamp",
                "endTimestamp",
                "sourceRevision",
                "numberOfMeasurements",
                "harmonized"
            ],
            in: dictionary,
            make: Electrocardiogram.make
        )
        assertEachKeyIsRequired(
            [
                "averageHeartRateUnit",
                "samplingFrequency",
                "samplingFrequencyUnit",
                "classification",
                "symptomsStatus",
                "count"
            ],
            in: harmonizedDictionary,
            make: Electrocardiogram.Harmonized.make
        )
        assertEachKeyIsRequired(
            ["harmonized", "timeSinceSampleStart"],
            in: voltageMeasurementDictionary,
            make: Electrocardiogram.VoltageMeasurement.make
        )
        assertEachKeyIsRequired(
            ["value", "unit"],
            in: ["value": 0.0001, "unit": "V"],
            make: Electrocardiogram.VoltageMeasurement.Harmonized.make
        )
    }
    func testCreateFromDictionarySkipsNonDictionaryVoltageMeasurements() throws {
        var harmonized = harmonizedDictionary
        harmonized["voltageMeasurements"] = [voltageMeasurementDictionary, "invalid", 1]
        harmonized.removeValue(forKey: "averageHeartRate")
        var dictionary = dictionary
        dictionary.removeValue(forKey: "device")
        dictionary["harmonized"] = harmonized
        let sut = try Electrocardiogram.make(from: dictionary)
        XCTAssertNil(sut.device)
        XCTAssertNil(sut.harmonized.averageHeartRate)
        XCTAssertEqual(sut.harmonized.voltageMeasurements.count, 1)
        XCTAssertEqual(sut.harmonized.voltageMeasurements[0].harmonized.value, 0.0001, accuracy: 0.000001)
        XCTAssertEqual(sut.harmonized.voltageMeasurements[0].harmonized.unit, "V")
        XCTAssertEqual(sut.harmonized.voltageMeasurements[0].timeSinceSampleStart, 0.5, accuracy: 0.001)
    }
    func testCreateFromDictionarySkipsInvalidVoltageMeasurements() throws {
        var harmonized = harmonizedDictionary
        harmonized["voltageMeasurements"] = [["timeSinceSampleStart": 0.5], voltageMeasurementDictionary]
        var dictionary = dictionary
        dictionary["harmonized"] = harmonized
        let sut = try Electrocardiogram.make(from: dictionary)
        XCTAssertEqual(sut.harmonized.voltageMeasurements.count, 1)
        XCTAssertEqual(sut.harmonized.voltageMeasurements[0].timeSinceSampleStart, 0.5, accuracy: 0.001)
    }
}
