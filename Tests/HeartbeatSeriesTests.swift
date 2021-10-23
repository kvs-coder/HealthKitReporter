//
//  HeartbeatSeriesTests.swift
//  
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKitReporter

@available(iOS 13.0, *)
class HeartbeatSeriesTests: XCTestCase {
    func testCreateFromDictionary() throws {
        let dictionary: [String: Any] = [
            "device" : [
                "softwareVersion" : "8.0.1",
                "manufacturer" : "Apple Inc.",
                "model" : "Watch",
                "name" : "Apple Watch",
                "hardwareVersion" : "Watch6,1"
            ],
            "sourceRevision" : [
                "productType" : "Watch6,1",
                "systemVersion" : "8.0.1",
                "source" : [
                    "name" : "Apple Watch von Victor",
                    "bundleIdentifier" : "com.apple.health.9482C212-CB6B-4949-A400-E448CCA82CEF"
                ],
                "operatingSystem" : [
                    "majorVersion" : 8,
                    "minorVersion" : 0,
                    "patchVersion" : 1
                ],
                "version" : "8.0.1"
            ],
            "uuid" : "061C93C9-95BD-476F-B170-3CDC504F7040",
            "identifier" : "HKDataTypeIdentifierHeartbeatSeries",
            "startTimestamp" : 1634151953.7457912,
            "endTimestamp" : 1634152011.8551662,
            "harmonized" : [
                "count" : 41,
                "measurements" : [
                    [
                        "precededByGap" : true,
                        "done" : false,
                        "timeSinceSeriesStart" : 1.30859375
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 2.58203125
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 3.82421875
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 5.0234375
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 6.203125
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 7.47265625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 8.63671875
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 9.84765625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 11.140625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 12.3125
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 13.5234375
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 14.7734375
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 15.94140625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 17.15234375
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 18.4296875
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 19.578125
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 20.79296875
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 22.0546875
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 23.19140625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 24.37890625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 25.609375
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 26.72265625
                    ],
                    [
                        "precededByGap" : true,
                        "done" : false,
                        "timeSinceSeriesStart" : 31.265625
                    ],
                    [
                        "precededByGap" : true,
                        "done" : false,
                        "timeSinceSeriesStart" : 32.5
                    ],
                    [
                        "precededByGap" : true,
                        "done" : false,
                        "timeSinceSeriesStart" : 34.8984375
                    ],
                    [
                        "precededByGap" : true,
                        "done" : false,
                        "timeSinceSeriesStart" : 39.45703125
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 40.66015625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 41.97265625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 43.21484375
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 44.421875
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 45.703125
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 46.9140625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 48.10546875
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 49.390625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 50.55078125
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 51.75
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 53.07421875
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 54.265625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 55.4140625
                    ],
                    [
                        "precededByGap" : false,
                        "done" : false,
                        "timeSinceSeriesStart" : 56.79296875
                    ],
                    [
                        "precededByGap" : false,
                        "done" : true,
                        "timeSinceSeriesStart" : 58.109375
                    ]
                ],
                "metadata" : [
                    "HKAlgorithmVersion" : "1"
                ]
            ]
        ]
        let epsilon = 1.0
        let sut = try HeartbeatSeries.make(from: dictionary)
        XCTAssertEqual(sut.identifier, "HKDataTypeIdentifierHeartbeatSeries")
        XCTAssertEqual(sut.startTimestamp, 1634151953.7457912, accuracy: epsilon)
        XCTAssertEqual(sut.endTimestamp, 1634152011.8551662, accuracy: epsilon)
        XCTAssertEqual(sut.device?.name, "Apple Watch")
        XCTAssertEqual(sut.device?.manufacturer, "Apple Inc.")
        XCTAssertEqual(sut.device?.model, "Watch")
        XCTAssertEqual(sut.device?.hardwareVersion, "Watch6,1")
        XCTAssertEqual(sut.device?.softwareVersion, "8.0.1")
        XCTAssertEqual(sut.sourceRevision.source.name, "Apple Watch von Victor")
        XCTAssertEqual(sut.sourceRevision.source.bundleIdentifier, "com.apple.health.9482C212-CB6B-4949-A400-E448CCA82CEF")
        XCTAssertEqual(sut.sourceRevision.version, "8.0.1")
        XCTAssertEqual(sut.sourceRevision.productType, "Watch6,1")
        XCTAssertEqual(sut.sourceRevision.systemVersion, "8.0.1")
        XCTAssertEqual(sut.sourceRevision.operatingSystem.majorVersion, 8)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.minorVersion, 0)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(sut.harmonized.count, 41)
        XCTAssertEqual(sut.harmonized.measurements.count, 41)
        XCTAssertEqual(sut.harmonized.measurements[0].precededByGap, true)
        XCTAssertEqual(sut.harmonized.measurements[0].done, false)
        XCTAssertEqual(sut.harmonized.measurements[0].timeSinceSeriesStart, 1.30859375)
        XCTAssertEqual(sut.harmonized.measurements[1].precededByGap, false)
        XCTAssertEqual(sut.harmonized.measurements[1].done, false)
        XCTAssertEqual(sut.harmonized.measurements[1].timeSinceSeriesStart, 2.58203125)
        XCTAssertEqual(sut.harmonized.measurements.last?.precededByGap, false)
        XCTAssertEqual(sut.harmonized.measurements.last?.done, true)
        XCTAssertEqual(sut.harmonized.measurements.last?.timeSinceSeriesStart, 58.109375)
        XCTAssertEqual(sut.harmonized.metadata, ["HKAlgorithmVersion" : "1"])
    }
}
