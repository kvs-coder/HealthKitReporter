//
//  WorkoutRouteTests.swift
//  
//
//  Created by Kachalov, Victor on 04.09.21.
//

import XCTest
import HealthKitReporter

@available(iOS 11.0, *)
class WorkoutRouteTests: XCTestCase {
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
                    "name" : "Apple Watch von Victor",
                    "bundleIdentifier" : "com.apple.health.9482C212-CB6B-4949-A400-E448CCA82CEF"
                ],
                "operatingSystem" : [
                    "majorVersion" : 8,
                    "minorVersion" : 5,
                    "patchVersion" : 1
                ],
                "version" : "8.5.1"
            ],
            "uuid" : "15431FED-4009-4764-9B4F-9FDD64827335",
            "identifier" : "HKWorkoutRouteTypeIdentifier",
            "startTimestamp" : 1650106382.259656,
            "endTimestamp" : 1650107789.9993167,
            "harmonized" : [
                "count" : 2,
                "metadata" : [
                    "HKMetadataKeySyncVersion" : "2",
                    "HKMetadataKeySyncIdentifier" : "8DA1E494-C047-4610-967F-267D60BD6E16"
                ],
                "routes" : [
                    [
                        "locations" : [
                            [
                                "floor": 1,
                                "course" : 211.54032897949219,
                                "speed" : 0.124705970287323,
                                "longitude" : 13.354639734623429,
                                "horizontalAccuracy" : 2.3436229228973389,
                                "verticalAccuracy" : 1.3776830434799194,
                                "latitude" : 52.517285348919636,
                                "courseAccuracy" : 398.32894897460938,
                                "speedAccuracy" : 0.86697620153427124,
                                "altitude" : 36.923385620117188,
                                "timestamp" : 1650106382.259656,
                            ],
                            [
                                "course" : 212.49124145507812,
                                "speed" : 0.14083768427371979,
                                "longitude" : 13.354638966592331,
                                "horizontalAccuracy" : 2.0688667297363281,
                                "verticalAccuracy" : 1.2691746950149536,
                                "latitude" : 52.517284600413831,
                                "courseAccuracy" : 290.92919921875,
                                "speedAccuracy" : 0.71512973308563232,
                                "altitude" : 36.95831298828125,
                                "timestamp" : 1650106382.9997792
                            ],
                        ],
                        "done": false
                    ],
                    [
                        "locations" : [
                            [
                                "course" : 181.96142578125,
                                "speed" : 4.3713326454162598,
                                "longitude" : 13.385890186794727,
                                "horizontalAccuracy" : 3.2566030025482178,
                                "verticalAccuracy" : 1.7064602375030518,
                                "latitude" : 52.48740014749324,
                                "courseAccuracy" : 6.4161453247070312,
                                "speedAccuracy" : 0.53145873546600342,
                                "altitude" : 46.786865234375,
                                "timestamp" : 1650107481.9998665
                            ],
                            [
                                "course" : 182.047607421875,
                                "speed" : 4.3631305694580078,
                                "longitude" : 13.385887939659334,
                                "horizontalAccuracy" : 3.2557823657989502,
                                "verticalAccuracy" : 1.7118692398071289,
                                "latitude" : 52.487360925517542,
                                "courseAccuracy" : 6.4148092269897461,
                                "speedAccuracy" : 0.53077465295791626,
                                "altitude" : 46.917694091796875,
                                "timestamp" : 1650107482.9998574
                            ],
                        ],
                        "done": true
                    ]

                ]
            ]
        ]
        let epsilon = 1.0
        let sut = try WorkoutRoute.make(from: dictionary)
        XCTAssertEqual(sut.identifier, "HKWorkoutRouteTypeIdentifier")
        XCTAssertEqual(sut.startTimestamp, 1650106382.259656, accuracy: epsilon)
        XCTAssertEqual(sut.endTimestamp, 1650107789.9993167, accuracy: epsilon)
        XCTAssertEqual(sut.device?.name, "Apple Watch")
        XCTAssertEqual(sut.device?.manufacturer, "Apple Inc.")
        XCTAssertEqual(sut.device?.model, "Watch")
        XCTAssertEqual(sut.device?.hardwareVersion, "Watch6,1")
        XCTAssertEqual(sut.device?.softwareVersion, "8.5.1")
        XCTAssertEqual(sut.sourceRevision.source.name, "Apple Watch von Victor")
        XCTAssertEqual(sut.sourceRevision.source.bundleIdentifier, "com.apple.health.9482C212-CB6B-4949-A400-E448CCA82CEF")
        XCTAssertEqual(sut.sourceRevision.version, "8.5.1")
        XCTAssertEqual(sut.sourceRevision.productType, "Watch6,1")
        XCTAssertEqual(sut.sourceRevision.systemVersion, "8.5.1")
        XCTAssertEqual(sut.sourceRevision.operatingSystem.majorVersion, 8)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.minorVersion, 5)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(sut.harmonized.count, 2)
        XCTAssertEqual(sut.harmonized.routes.count, 2)
        XCTAssertEqual(sut.harmonized.routes[0].done, false)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].course, 211.54032897949219, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].speed, 0.124705970287323, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].longitude, 13.354639734623429, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].horizontalAccuracy, 2.3436229228973389, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].verticalAccuracy, 1.3776830434799194, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].latitude, 52.517285348919636, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].courseAccuracy!, 398.32894897460938, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].speedAccuracy!, 0.86697620153427124, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].altitude, 36.923385620117188, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].timestamp, 1650106382.259656, accuracy: epsilon)
        XCTAssertEqual(sut.harmonized.routes[0].locations[0].floor, 1)
        XCTAssertEqual(
            sut.harmonized.metadata, [
                "HKMetadataKeySyncVersion" : "2",
                "HKMetadataKeySyncIdentifier" : "8DA1E494-C047-4610-967F-267D60BD6E16"
            ]
        )
    }
}
