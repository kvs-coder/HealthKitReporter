//
//  CategoryTypeTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

class CategoryTypeTests: XCTestCase {
    func testAllCases() throws {
        for sut in CategoryType.allCases {
            let original = try XCTUnwrap(sut.original, "\(sut)")
            XCTAssertEqual(sut.identifier, original.identifier, "\(sut)")
            let identifier = try XCTUnwrap(sut.identifier, "\(sut)")
            // environmentalAudioExposureEvent shares its identifier with the earlier audioExposureEvent case
            // (HKCategoryTypeIdentifierAudioExposureEvent), so make(from:) resolves it to audioExposureEvent.
            let expected: CategoryType = sut == .environmentalAudioExposureEvent
                ? .audioExposureEvent
                : sut
            XCTAssertEqual(try CategoryType.make(from: identifier), expected, "\(sut)")
        }
    }
    func testAudioExposureEventIdentifier() throws {
        let sut = CategoryType.audioExposureEvent
        XCTAssertEqual(sut.identifier, "HKCategoryTypeIdentifierAudioExposureEvent")
        XCTAssertNotNil(sut.original)
    }
    func testAudioExposureEventMatchesEnvironmentalAudioExposureEvent() throws {
        let sut = CategoryType.audioExposureEvent
        XCTAssertEqual(sut.identifier, CategoryType.environmentalAudioExposureEvent.identifier)
    }
    func testMakeFromInvalidIdentifier() throws {
        XCTAssertThrowsError(try CategoryType.make(from: "invalid")) { error in
            guard case HealthKitError.invalidIdentifier = error else {
                XCTFail("Expected HealthKitError.invalidIdentifier, got \(error)")
                return
            }
        }
    }
}
