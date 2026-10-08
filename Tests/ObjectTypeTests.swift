//
//  ObjectTypeTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

class ObjectTypeTests: XCTestCase {
    func testQuantityTypeAllCases() throws {
        try assertAllCases(QuantityType.self)
        try assertSampleTypeIdentifiers(QuantityType.self)
    }
    func testCharacteristicTypeAllCases() throws {
        try assertAllCases(CharacteristicType.self)
    }
    func testCorrelationTypeAllCases() throws {
        try assertAllCases(CorrelationType.self)
        try assertSampleTypeIdentifiers(CorrelationType.self)
    }
    func testSeriesTypeAllCases() throws {
        try assertAllCases(SeriesType.self)
        try assertSampleTypeIdentifiers(SeriesType.self)
    }
    func testElectrocardiogramTypeAllCases() throws {
        try assertAllCases(ElectrocardiogramType.self)
        try assertSampleTypeIdentifiers(ElectrocardiogramType.self)
    }
    func testClinicalTypeAllCases() throws {
        try assertAllCases(ClinicalType.self)
        try assertSampleTypeIdentifiers(ClinicalType.self)
    }
    func testDocumentTypeAllCases() throws {
        try assertAllCases(DocumentType.self)
        try assertSampleTypeIdentifiers(DocumentType.self)
    }
    func testVisionPrescriptionTypeAllCases() throws {
        try assertAllCases(VisionPrescriptionType.self)
        try assertSampleTypeIdentifiers(VisionPrescriptionType.self)
    }
    func testActivitySummaryTypeAllCases() throws {
        try assertAllCases(ActivitySummaryType.self)
    }
    func testWorkoutTypeAllCases() throws {
        try assertAllCases(WorkoutType.self)
        try assertSampleTypeIdentifiers(WorkoutType.self)
    }
    func testWellbeingAndMedicationTypesAllCases() throws {
        try assertAllCases(AudiogramType.self)
        try assertSampleTypeIdentifiers(AudiogramType.self)
        guard #available(iOS 26.0, watchOS 26.0, *) else {
            throw XCTSkip("State of mind, assessments and medications require iOS 26 to test together")
        }
        try assertAllCases(StateOfMindType.self)
        try assertSampleTypeIdentifiers(StateOfMindType.self)
        try assertAllCases(ScoredAssessmentType.self)
        try assertSampleTypeIdentifiers(ScoredAssessmentType.self)
        try assertAllCases(MedicationType.self)
    }
    func testQuantityTypeMakeFromIdentifiersAddedSinceIOS16() throws {
        let identifiers: [String: QuantityType] = [
            "HKQuantityTypeIdentifierEnvironmentalSoundReduction": .environmentalSoundReduction,
            "HKQuantityTypeIdentifierCyclingCadence": .cyclingCadence,
            "HKQuantityTypeIdentifierCyclingFunctionalThresholdPower": .cyclingFunctionalThresholdPower,
            "HKQuantityTypeIdentifierCyclingPower": .cyclingPower,
            "HKQuantityTypeIdentifierCyclingSpeed": .cyclingSpeed,
            "HKQuantityTypeIdentifierPhysicalEffort": .physicalEffort,
            "HKQuantityTypeIdentifierTimeInDaylight": .timeInDaylight,
            "HKQuantityTypeIdentifierCrossCountrySkiingSpeed": .crossCountrySkiingSpeed,
            "HKQuantityTypeIdentifierDistanceCrossCountrySkiing": .distanceCrossCountrySkiing,
            "HKQuantityTypeIdentifierDistancePaddleSports": .distancePaddleSports,
            "HKQuantityTypeIdentifierPaddleSportsSpeed": .paddleSportsSpeed,
            "HKQuantityTypeIdentifierDistanceRowing": .distanceRowing,
            "HKQuantityTypeIdentifierRowingSpeed": .rowingSpeed,
            "HKQuantityTypeIdentifierDistanceSkatingSports": .distanceSkatingSports,
            "HKQuantityTypeIdentifierWorkoutEffortScore": .workoutEffortScore,
            "HKQuantityTypeIdentifierEstimatedWorkoutEffortScore": .estimatedWorkoutEffortScore,
            "HKQuantityTypeIdentifierAppleSleepingBreathingDisturbances": .appleSleepingBreathingDisturbances
        ]
        for (identifier, sut) in identifiers {
            XCTAssertEqual(try QuantityType.make(from: identifier), sut, identifier)
            XCTAssertEqual(sut.identifier, identifier)
        }
    }
    func testMakeFromInvalidIdentifier() throws {
        XCTAssertThrowsError(try QuantityType.make(from: "invalid")) { error in
            guard case HealthKitError.invalidIdentifier = error else {
                XCTFail("Expected HealthKitError.invalidIdentifier, got \(error)")
                return
            }
        }
    }
    func testStringObjectType() throws {
        XCTAssertNotNil("HKQuantityTypeIdentifierStepCount".objectType as? QuantityType)
        XCTAssertNotNil("HKCategoryTypeIdentifierSleepAnalysis".objectType as? CategoryType)
        XCTAssertNotNil("HKCharacteristicTypeIdentifierBloodType".objectType as? CharacteristicType)
        XCTAssertNotNil("HKWorkoutRouteTypeIdentifier".objectType as? SeriesType)
        XCTAssertNotNil("HKCorrelationTypeIdentifierBloodPressure".objectType as? CorrelationType)
        XCTAssertNotNil("HKDocumentTypeIdentifierCDA".objectType as? DocumentType)
        XCTAssertNotNil("HKActivitySummaryTypeIdentifier".objectType as? ActivitySummaryType)
        XCTAssertNotNil("HKWorkoutTypeIdentifier".objectType as? WorkoutType)
        XCTAssertNotNil("HKDataTypeIdentifierElectrocardiogram".objectType as? ElectrocardiogramType)
        XCTAssertNotNil("HKClinicalTypeIdentifierAllergyRecord".objectType as? ClinicalType)
        XCTAssertNotNil("HKVisionPrescriptionTypeIdentifier".objectType as? VisionPrescriptionType)
        XCTAssertNil("invalid".objectType)
    }
    func testSampleTypePredicates() throws {
        let predicate = NSPredicate.samplesPredicate(startDate: startDate, endDate: endDate)
        let predicates: [String: NSPredicate] = [
            "HKQuantityTypeIdentifierStepCount": predicate,
            "HKCategoryTypeIdentifierSleepAnalysis": predicate,
            "HKClinicalTypeIdentifierAllergyRecord": predicate,
            "HKVisionPrescriptionTypeIdentifier": predicate,
            "HKCharacteristicTypeIdentifierBloodType": predicate,
            "invalid": predicate
        ]
        let sut = predicates.sampleTypePredicates
        XCTAssertEqual(
            Set(sut.keys.map(\.identifier)),
            [
                "HKQuantityTypeIdentifierStepCount",
                "HKCategoryTypeIdentifierSleepAnalysis",
                "HKClinicalTypeIdentifierAllergyRecord",
                "HKVisionPrescriptionTypeIdentifier"
            ]
        )
        XCTAssertTrue(sut.values.allSatisfy { $0 == predicate })
    }

    private func assertAllCases<T: ObjectType & CaseIterable & Equatable>(
        _ type: T.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        for sut in T.allCases {
            let original = try XCTUnwrap(sut.original, "\(sut)", file: file, line: line)
            XCTAssertEqual(try T.make(from: original.identifier), sut, "\(sut)", file: file, line: line)
        }
    }
    private func assertSampleTypeIdentifiers<T: SampleType & CaseIterable>(
        _ type: T.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        for sut in T.allCases {
            XCTAssertNotNil(sut.identifier, "\(sut)", file: file, line: line)
            XCTAssertEqual(sut.identifier, sut.original?.identifier, "\(sut)", file: file, line: line)
        }
    }
}
