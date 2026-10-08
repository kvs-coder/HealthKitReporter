//
//  CategoryTypeTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

class CategoryTypeTests: XCTestCase {
    func testAudioExposureEventIdentifier() throws {
        let sut = CategoryType.audioExposureEvent
        XCTAssertEqual(sut.identifier, "HKCategoryTypeIdentifierAudioExposureEvent")
        XCTAssertNotNil(sut.original)
    }
    func testAudioExposureEventMatchesEnvironmentalAudioExposureEvent() throws {
        let sut = CategoryType.audioExposureEvent
        XCTAssertEqual(sut.identifier, CategoryType.environmentalAudioExposureEvent.identifier)
    }
}
