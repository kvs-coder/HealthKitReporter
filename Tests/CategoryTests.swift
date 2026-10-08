//
//  CategoryTests.swift
//  
//
//  Created by Kachalov, Victor on 03.09.21.
//

import XCTest
import HealthKit
import HealthKitReporter

class CategoryTests: XCTestCase {
    func testCreateThenEncodeThenDecode() throws {
        let startDate = Date(timeIntervalSince1970: 1626884800)
        let endDate = startDate.addingTimeInterval(60)
        let sut = Category(
            identifier: CategoryType.sleepAnalysis.identifier!,
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
            harmonized: Category.Harmonized(
                value: 1,
                description: "HKCategoryValueSleepAnalysis",
                detail: "Asleep",
                metadata: ["HKWasUserEntered": "1"]
            )
        )
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            Category.self,
            from: encoded.data(using: .utf8)!
        )
        XCTAssertEqual(decoded.identifier, "HKCategoryTypeIdentifierSleepAnalysis")
        XCTAssertEqual(decoded.startTimestamp, 1626884800)
        XCTAssertEqual(decoded.endTimestamp, 1626884800 + 60)
        XCTAssertEqual(decoded.device?.name, "Guy's iPhone")
        XCTAssertEqual(decoded.device?.manufacturer, "Guy")
        XCTAssertEqual(decoded.device?.model, "6.1.1")
        XCTAssertEqual(decoded.device?.hardwareVersion, "some_0")
        XCTAssertEqual(decoded.device?.firmwareVersion, "some_1")
        XCTAssertEqual(decoded.device?.softwareVersion, "some_2")
        XCTAssertEqual(decoded.device?.localIdentifier, "some_3")
        XCTAssertEqual(decoded.device?.udiDeviceIdentifier, "some_4")
        XCTAssertEqual(decoded.sourceRevision.source.name, "mySource")
        XCTAssertEqual(decoded.sourceRevision.source.bundleIdentifier, "com.kvs.hkreporter")
        XCTAssertEqual(decoded.sourceRevision.version, "1.0.0")
        XCTAssertEqual(decoded.sourceRevision.productType, "CocoaPod")
        XCTAssertEqual(decoded.sourceRevision.systemVersion, "1.0.0.0")
        XCTAssertEqual(decoded.sourceRevision.operatingSystem.majorVersion, 1)
        XCTAssertEqual(decoded.sourceRevision.operatingSystem.minorVersion, 1)
        XCTAssertEqual(decoded.sourceRevision.operatingSystem.patchVersion, 1)
        XCTAssertEqual(decoded.harmonized.value, 1)
        XCTAssertEqual(decoded.harmonized.description, "HKCategoryValueSleepAnalysis")
        XCTAssertEqual(decoded.harmonized.detail, "Asleep")
        XCTAssertEqual(decoded.harmonized.metadata, ["HKWasUserEntered": "1"])
    }
    func testCreateFromDictionary() throws {
        let dictionary: [String: Any] = [
            "identifier": "HKCategoryTypeIdentifierSleepAnalysis",
            "startTimestamp": 1630618680,
            "endTimestamp": 1630697880,
            "device": [
                "name": nil,
                "manufacturer": nil,
                "model": nil,
                "hardwareVersion": nil,
                "firmwareVersion": nil,
                "softwareVersion": nil,
                "localIdentifier": nil,
                "udiDeviceIdentifier": nil
            ],
            "sourceRevision": [
                "source": [
                    "name": "Health",
                    "bundleIdentifier": "com.apple.Health"
                ],
                "version": "14.5",
                "productType": "iPhone13,3",
                "systemVersion": "14.5.0",
                "operatingSystem": [
                    "majorVersion": 14,
                    "minorVersion": 5,
                    "patchVersion": 0
                ]
            ],
            "harmonized": [
                "value": 1,
                "description": "HKCategoryValueSleepAnalysis",
                "detail": "Asleep",
                "metadata": [
                    "HKWasUserEntered": "1"
                ]
            ]
        ]
        let epsilon = 1.0
        let sut = try Category.make(from: dictionary)
        XCTAssertEqual(sut.identifier, "HKCategoryTypeIdentifierSleepAnalysis")
        XCTAssertEqual(sut.startTimestamp, 1630618680, accuracy: epsilon)
        XCTAssertEqual(sut.endTimestamp, 1630697880, accuracy: epsilon)
        XCTAssertNil(sut.device?.name)
        XCTAssertNil(sut.device?.manufacturer)
        XCTAssertNil(sut.device?.model)
        XCTAssertNil(sut.device?.hardwareVersion)
        XCTAssertNil(sut.device?.firmwareVersion)
        XCTAssertNil(sut.device?.softwareVersion)
        XCTAssertNil(sut.device?.localIdentifier)
        XCTAssertNil(sut.device?.udiDeviceIdentifier)
        XCTAssertEqual(sut.sourceRevision.source.name, "Health")
        XCTAssertEqual(sut.sourceRevision.source.bundleIdentifier, "com.apple.Health")
        XCTAssertEqual(sut.sourceRevision.version, "14.5")
        XCTAssertEqual(sut.sourceRevision.productType, "iPhone13,3")
        XCTAssertEqual(sut.sourceRevision.systemVersion, "14.5.0")
        XCTAssertEqual(sut.sourceRevision.operatingSystem.majorVersion, 14)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.minorVersion, 5)
        XCTAssertEqual(sut.sourceRevision.operatingSystem.patchVersion, 0)
        XCTAssertEqual(sut.harmonized.value, 1)
        XCTAssertEqual(sut.harmonized.description, "HKCategoryValueSleepAnalysis")
        XCTAssertEqual(sut.harmonized.detail, "Asleep")
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": "1"])
    }
    private var harmonizedDictionary: [String: Any] {
        return [
            "value": 1,
            "description": "HKCategoryValueSleepAnalysis",
            "detail": "Asleep",
            "metadata": [
                "HKWasUserEntered": "1"
            ]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKCategoryTypeIdentifierSleepAnalysis",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": harmonizedDictionary
        ]
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: dictionary,
            make: Category.make
        )
        assertEachKeyIsRequired(
            ["value", "description", "detail"],
            in: harmonizedDictionary,
            make: Category.Harmonized.make
        )
    }
    func testCreateFromDictionaryWithoutDevice() throws {
        var dictionary = dictionary
        dictionary.removeValue(forKey: "device")
        let sut = try Category.make(from: dictionary)
        XCTAssertNil(sut.device)
    }
    func testCopyWithNoArgumentsKeepsAllFields() throws {
        let sut = try Category.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
    }
    func testCopyWithChangesOnlyGivenField() throws {
        let sut = try Category.make(from: dictionary)
        let copy = sut.copyWith(endTimestamp: 1)
        XCTAssertEqual(copy.endTimestamp, 1, accuracy: 0.001)
        XCTAssertEqual(
            try json(copy, excluding: ["endTimestamp"]),
            try json(sut, excluding: ["endTimestamp"])
        )
        let harmonized = sut.harmonized.copyWith(detail: "InBed")
        XCTAssertEqual(harmonized.detail, "InBed")
        XCTAssertEqual(
            try json(harmonized, excluding: ["detail"]),
            try json(sut.harmonized, excluding: ["detail"])
        )
    }
    func testCollectSkipsNonDictionaryElements() throws {
        let sut = try Category.collect(from: [dictionary, "invalid", 1, dictionary])
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut[0].identifier, "HKCategoryTypeIdentifierSleepAnalysis")
        XCTAssertEqual(sut[1].identifier, "HKCategoryTypeIdentifierSleepAnalysis")
    }
    func testCollectThrowsOnInvalidDictionary() throws {
        assertInvalidValue(try Category.collect(from: [dictionary, ["identifier": "invalid"]]))
    }
}
// MARK: - Factory
extension CategoryTests {
    /// Valid sample values for types whose value enum has no case at 0
    private var values: [CategoryType: Int] {
        var values: [CategoryType: Int] = [
            .menstrualFlow: HKCategoryValueMenstrualFlow.unspecified.rawValue,
            .ovulationTestResult: HKCategoryValueOvulationTestResult.negative.rawValue,
            .cervicalMucusQuality: HKCategoryValueCervicalMucusQuality.dry.rawValue,
            .contraceptive: HKCategoryValueContraceptive.unspecified.rawValue,
            .audioExposureEvent: HKCategoryValueEnvironmentalAudioExposureEvent.momentaryLimit.rawValue,
            .environmentalAudioExposureEvent:
                HKCategoryValueEnvironmentalAudioExposureEvent.momentaryLimit.rawValue,
            .headphoneAudioExposureEvent: HKCategoryValueHeadphoneAudioExposureEvent.sevenDayLimit.rawValue,
            .lowCardioFitnessEvent: HKCategoryValueLowCardioFitnessEvent.lowFitness.rawValue,
            .pregnancyTestResult: HKCategoryValuePregnancyTestResult.negative.rawValue,
            .progesteroneTestResult: HKCategoryValueProgesteroneTestResult.negative.rawValue,
            .appleWalkingSteadinessEvent: HKCategoryValueAppleWalkingSteadinessEvent.initialLow.rawValue
        ]
        if #available(iOS 18.0, *) {
            values[.bleedingAfterPregnancy] = HKCategoryValueVaginalBleeding.light.rawValue
            values[.bleedingDuringPregnancy] = HKCategoryValueVaginalBleeding.heavy.rawValue
        }
        return values
    }

    func testCollectResults() throws {
        let sample = HKCategorySample(
            type: HKCategoryType(.sleepAnalysis),
            value: HKCategoryValueSleepAnalysis.awake.rawValue,
            start: startDate,
            end: endDate,
            device: HKDevice(
                name: "Guy's iPhone",
                manufacturer: "Guy",
                model: "6.1.1",
                hardwareVersion: "some_0",
                firmwareVersion: "some_1",
                softwareVersion: "some_2",
                localIdentifier: "some_3",
                udiDeviceIdentifier: "some_4"
            ),
            metadata: ["you": "saved it"]
        )
        let sut = Category.collect(results: [sample])
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[0].uuid, sample.uuid.uuidString)
        XCTAssertEqual(sut[0].identifier, "HKCategoryTypeIdentifierSleepAnalysis")
        XCTAssertEqual(sut[0].startTimestamp, 1626884800, accuracy: 0.001)
        XCTAssertEqual(sut[0].endTimestamp, 1626884860, accuracy: 0.001)
        assertDevice(sut[0].device)
        XCTAssertEqual(sut[0].harmonized.value, HKCategoryValueSleepAnalysis.awake.rawValue)
        XCTAssertEqual(sut[0].harmonized.description, "HKCategoryValueSleepAnalysis")
        XCTAssertEqual(sut[0].harmonized.detail, "Awake")
        XCTAssertEqual(sut[0].harmonized.metadata, ["you": "saved it"])
    }
    func testCollectResultsIgnoresOtherSamples() throws {
        let sample = HKQuantitySample(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 1),
            start: startDate,
            end: endDate
        )
        XCTAssertTrue(Category.collect(results: [sample]).isEmpty)
    }
    func testHarmonizeEveryCategoryType() throws {
        for type in CategoryType.allCases {
            let original = try XCTUnwrap(type.original as? HKCategoryType, "\(type)")
            let value = values[type] ?? 0
            let sample = HKCategorySample(
                type: original,
                value: value,
                start: startDate,
                end: endDate,
                metadata: type == .menstrualFlow ? [HKMetadataKeyMenstrualCycleStart: true] : nil
            )
            let sut = try XCTUnwrap(Category.collect(results: [sample]).first, "\(type)")
            XCTAssertEqual(sut.identifier, original.identifier, "\(type)")
            XCTAssertEqual(sut.harmonized.value, value, "\(type)")
            XCTAssertTrue(sut.harmonized.description.hasPrefix("HKCategoryValue"), "\(type)")
            XCTAssertFalse(sut.harmonized.detail.isEmpty, "\(type)")
            XCTAssertNotEqual(sut.harmonized.detail, "Unknown", "\(type)")
        }
    }
    func testHarmonizeVaginalBleedingValues() throws {
        guard #available(iOS 18.0, *) else {
            throw XCTSkip("HKCategoryValueVaginalBleeding requires iOS 18")
        }
        let details: [HKCategoryValueVaginalBleeding: String] = [
            .unspecified: "Unspecified",
            .light: "Light",
            .medium: "Medium",
            .heavy: "Heavy",
            .none: "None"
        ]
        for type in [CategoryType.bleedingAfterPregnancy, .bleedingDuringPregnancy] {
            let original = try XCTUnwrap(type.original as? HKCategoryType, "\(type)")
            for (value, detail) in details {
                let sample = HKCategorySample(
                    type: original,
                    value: value.rawValue,
                    start: startDate,
                    end: endDate
                )
                let sut = try XCTUnwrap(Category.collect(results: [sample]).first, "\(type): \(detail)")
                XCTAssertEqual(sut.harmonized.value, value.rawValue, "\(type): \(detail)")
                XCTAssertEqual(sut.harmonized.description, "HKCategoryValueVaginalBleeding", "\(type)")
                XCTAssertEqual(sut.harmonized.detail, detail, "\(type)")
            }
        }
    }
}
