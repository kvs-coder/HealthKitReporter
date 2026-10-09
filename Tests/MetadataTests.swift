//
//  MetadataTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 29.10.22.
//

import XCTest
import HealthKit
import HealthKitReporter

class MetadataTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

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

    /// HealthKit metadata quantities don't expose their unit; the first compatible unit expresses them
    func testCreateFromHealthKitQuantities() throws {
        let sut = try Metadata.make(from: [
            "HKHeartRateEventThreshold": HKQuantity(
                unit: .count().unitDivided(by: .minute()),
                doubleValue: 120
            ),
            "HKWeatherTemperature": HKQuantity(unit: .degreeCelsius(), doubleValue: 21),
            "HKLapLength": HKQuantity(unit: .meter(), doubleValue: 25),
            "HKElevationAscended": HKQuantity(unit: .meterUnit(with: .centi), doubleValue: 300),
            "HKWeatherHumidity": HKQuantity(unit: .percent(), doubleValue: 0.4)
        ])
        let expected: Metadata = [
            "HKHeartRateEventThreshold": .quantity(value: 120, unit: "count/min"),
            "HKWeatherTemperature": .quantity(value: 21, unit: "degC"),
            "HKLapLength": .quantity(value: 25, unit: "m"),
            "HKElevationAscended": .quantity(value: 3, unit: "m"),
            "HKWeatherHumidity": .quantity(value: 0.4, unit: "%")
        ]
        XCTAssertEqual(sut, expected)
        let amount = HKQuantity(unit: HKUnit(from: "mmol"), doubleValue: 1)
        assertInvalidValue(try Metadata.make(from: ["amount": amount]))
    }
    /// Concentrations, clinical and vision units have a unit to be expressed in too
    func testCreateFromHealthKitConcentrationsAndClinicalUnits() throws {
        let glucose = HKQuantity(
            unit: HKUnit
                .moleUnit(with: .milli, molarMass: HKUnitMolarMassBloodGlucose)
                .unitDivided(by: .liter()),
            doubleValue: 5.5
        )
        var quantities: [String: Any] = [
            "glucose": glucose,
            "glucoseMass": HKQuantity(unit: HKUnit(from: "mg/dL"), doubleValue: 99),
            "molar": HKQuantity(unit: HKUnit(from: "mmol/L"), doubleValue: 5.5),
            "insulin": HKQuantity(unit: .internationalUnit(), doubleValue: 4),
            "conductance": HKQuantity(unit: .siemen(), doubleValue: 2),
            "voltage": HKQuantity(unit: .voltUnit(with: .milli), doubleValue: 1),
            "flow": HKQuantity(unit: HKUnit(from: "mL/min"), doubleValue: 300),
            "hearing": HKQuantity(unit: .decibelHearingLevel(), doubleValue: 20)
        ]
        var expected: Metadata = [
            "glucoseMass": .quantity(value: 99, unit: "mg/dL"),
            "molar": .quantity(value: 5.5, unit: "mmol/L"),
            "insulin": .quantity(value: 4, unit: "IU"),
            "conductance": .quantity(value: 2, unit: "S"),
            "voltage": .quantity(value: 0.001, unit: "V"),
            "flow": .quantity(value: 0.3, unit: "L/min"),
            "hearing": .quantity(value: 20, unit: "dBHL")
        ]
        if #available(iOS 16.0, watchOS 9.0, *) {
            quantities["angle"] = HKQuantity(unit: .degreeAngle(), doubleValue: 30)
            quantities["sphere"] = HKQuantity(unit: .diopter(), doubleValue: -1.5)
            quantities["prism"] = HKQuantity(unit: .prismDiopter(), doubleValue: 0.5)
            expected = Metadata(expected.values.merging([
                "angle": .quantity(value: 30, unit: "deg"),
                "sphere": .quantity(value: -1.5, unit: "D"),
                "prism": .quantity(value: 0.5, unit: "pD")
            ]) { _, new in new })
        }
        let sut = try Metadata.make(from: quantities)
        for (key, value) in expected.values {
            guard
                case .quantity(let expectedValue, let expectedUnit) = value,
                case .quantity(let actualValue, let actualUnit)? = sut[key]
            else {
                XCTFail("\(key) is not a quantity: \(String(describing: sut[key]))")
                continue
            }
            XCTAssertEqual(actualValue, expectedValue, accuracy: 0.000001, key)
            XCTAssertEqual(actualUnit, expectedUnit, key)
        }
        guard case .quantity(let value, let unit)? = sut["glucose"] else {
            return XCTFail("glucose is not a quantity: \(String(describing: sut["glucose"]))")
        }
        XCTAssertEqual(value, 99.086, accuracy: 0.001)
        XCTAssertEqual(unit, "mg/dL")
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
        HealthKitReporter().writer.save(sample: invalid) { _, _, error in
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
