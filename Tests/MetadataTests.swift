//
//  MetadataTests.swift
//
//
//  Created by Victor Kachalov on 29.10.22.
//

import XCTest
import HealthKit
import HealthKitReporter

class MetadataTests: XCTestCase {
    /// Mixed metadata as the Flutter plugin sends it over the channel
    private var dictionary: [String: Any] {
        return [
            "HKTimeZone": "Europe/Berlin",
            "HKWasUserEntered": true,
            "HKAverageMETs": 4.5,
            "HKDateOfEarliestDataUsedForEstimate": ["timestamp": 1626884800],
            "HKHeartRateEventThreshold": ["value": 120, "unit": "count/min"]
        ]
    }
    private var expected: Metadata {
        return [
            "HKTimeZone": "Europe/Berlin",
            "HKWasUserEntered": true,
            "HKAverageMETs": 4.5,
            "HKDateOfEarliestDataUsedForEstimate": .date(timestamp: 1626884800),
            "HKHeartRateEventThreshold": .quantity(value: 120, unit: "count/min")
        ]
    }

    func testCreateFromDictionary() throws {
        let sut = try Metadata.make(from: dictionary)
        XCTAssertEqual(sut, expected)
        XCTAssertEqual(sut["HKTimeZone"], .string("Europe/Berlin"))
        XCTAssertEqual(sut["HKWasUserEntered"], .bool(true))
        XCTAssertEqual(sut["HKAverageMETs"], .number(4.5))
        XCTAssertNil(sut["missing"])
    }
    func testCreateThenEncodeThenDecode() throws {
        let encoded = try expected.encoded()
        let decoded = try JSONDecoder().decode(
            Metadata.self,
            from: try XCTUnwrap(encoded.data(using: .utf8))
        )
        XCTAssertEqual(decoded, expected)
    }
    func testEncodesAsFlatJSONObject() throws {
        let sut = try json(expected)
        XCTAssertEqual(sut["HKTimeZone"] as? String, "Europe/Berlin")
        XCTAssertEqual(sut["HKWasUserEntered"] as? Bool, true)
        XCTAssertEqual(sut["HKAverageMETs"] as? Double, 4.5)
        XCTAssertEqual(
            sut["HKDateOfEarliestDataUsedForEstimate"] as? NSDictionary,
            ["timestamp": 1626884800] as NSDictionary
        )
        XCTAssertEqual(
            sut["HKHeartRateEventThreshold"] as? NSDictionary,
            ["value": 120, "unit": "count/min"] as NSDictionary
        )
        XCTAssertEqual(try decode(Metadata.self, from: sut as? [String: Any] ?? [:]), expected)
    }
    func testCreateFromDictionaryWithUnsupportedValueThrows() throws {
        assertInvalidValue(try Metadata.make(from: ["key": [1, 2]]))
        assertInvalidValue(try Metadata.make(from: ["key": ["value": 1]]))
    }
    func testReadMixedMetadataFromHealthKit() throws {
        let sample = HKQuantitySample(
            type: HKQuantityType(.heartRate),
            quantity: HKQuantity(unit: .count().unitDivided(by: .minute()), doubleValue: 130),
            start: startDate,
            end: endDate,
            metadata: [
                HKMetadataKeyTimeZone: "Europe/Berlin",
                HKMetadataKeyWasUserEntered: true,
                HKMetadataKeyHeartRateEventThreshold: HKQuantity(
                    unit: .count().unitDivided(by: .minute()),
                    doubleValue: 120
                ),
                "custom date": startDate,
                "custom number": 7
            ]
        )
        let sut = try XCTUnwrap(parse([sample]).first as? Quantity)
        XCTAssertEqual(
            sut.harmonized.metadata,
            [
                "HKTimeZone": "Europe/Berlin",
                "HKWasUserEntered": true,
                "HKHeartRateEventThreshold": .quantity(value: 120, unit: "count/min"),
                "custom date": .date(timestamp: 1626884800),
                "custom number": 7
            ]
        )
    }
    func testWriteMixedMetadataToHealthKit() throws {
        let quantity = try Quantity.make(
            from: [
                "identifier": "HKQuantityTypeIdentifierHeartRate",
                "startTimestamp": startTimestamp,
                "endTimestamp": endTimestamp,
                "sourceRevision": sourceRevisionDictionary,
                "harmonized": [
                    "value": 130,
                    "unit": "count/min",
                    "metadata": dictionary
                ]
            ]
        )
        XCTAssertEqual(quantity.harmonized.metadata, expected)
        let invalid = quantity.copyWith(
            harmonized: quantity.harmonized.copyWith(
                metadata: ["HKHeartRateEventThreshold": .quantity(value: 120, unit: "notAUnit")]
            )
        )
        let expectation = expectation(description: "completion")
        var saveError: Error?
        HealthKitReporter().writer.save(sample: invalid) { _, error in
            saveError = error
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
        assertInvalidValue(try { throw try XCTUnwrap(saveError) }())
    }
    func testCreateFromInvalidPayloadDictionaryThrows() throws {
        assertInvalidValue(
            try Quantity.Harmonized.make(from: ["value": 1, "unit": "count", "metadata": ["key": [1]]])
        )
    }
}
