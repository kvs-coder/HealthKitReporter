//
//  HealthKitReaderTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

class HealthKitReaderTests: XCTestCase {
    /// **SampleType** whose original is not an **HKSampleType**
    /// **SampleType** the library can't turn into an **HKSampleType**
    private enum InvalidSampleType: SampleType {
        case characteristic
        case unavailable

        var identifier: String? {
            switch self {
            case .characteristic:
                return "HKCharacteristicTypeIdentifierBloodType"
            case .unavailable:
                return nil
            }
        }
    }

    private var sut: HealthKitReader!
    private let predicate = NSPredicate.samplesPredicate(
        startDate: Date(timeIntervalSince1970: 1626884800),
        endDate: Date(timeIntervalSince1970: 1626884860)
    )
    private let sortDescriptors = [
        NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: true
        )
    ]

    override func setUp() {
        super.setUp()
        sut = HealthKitReporter().reader
    }
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testAnchoredObjectQueryMonitoringUpdatesWithLimit() throws {
        XCTAssertThrowsError(
            try sut.anchoredObjectQuery(
                type: QuantityType.stepCount,
                limit: 10,
                monitorUpdates: true
            ) { _, _, _, _, _ in }
        ) { error in
            guard case HealthKitError.invalidOption = error else {
                XCTFail("Expected invalidOption, got \(error)")
                return
            }
        }
    }
    func testAnchoredObjectQueryWithInvalidType() throws {
        for type in [InvalidSampleType.characteristic, .unavailable] {
            assertInvalidType(try sut.anchoredObjectQuery(type: type) { _, _, _, _, _ in })
        }
    }
    func testSourceQueryWithInvalidType() throws {
        for type in [InvalidSampleType.characteristic, .unavailable] {
            assertInvalidType(try sut.sourceQuery(type: type) { _, _ in })
        }
    }
    func testMedicationDoseEventQueryWithInvalidMedication() throws {
        guard #available(iOS 26.0, watchOS 26.0, *) else {
            throw XCTSkip("Medications require iOS 26")
        }
        for identifier in ["not base64", Data("not an archive".utf8).base64EncodedString()] {
            assertInvalidValue(
                try sut.medicationDoseEventQuery(medicationConceptIdentifier: identifier) { _, _ in }
            )
        }
    }
    func testWorkoutRouteQueryWithInvalidWorkoutUUID() throws {
        for uuid in ["", "not-a-uuid", "8B1F9C1E-4E0A-4C38-9D57"] {
            assertInvalidValue(try sut.workoutRouteQuery(workoutUUID: uuid) { _, _ in })
        }
        XCTAssertNoThrow(
            try sut.workoutRouteQuery(workoutUUID: storedUUID.lowercased(), limit: 1) { _, _ in }
        )
    }
}
// MARK: - Units
extension HealthKitReaderTests {
    func testQueriesWithMalformedOrIncompatibleUnitThrow() throws {
        let anchorDate = Date(timeIntervalSince1970: 1626884800)
        for unit in ["kg", "notAUnit", "(m", "m//s", "m/s/s", "count^", ""] {
            assertInvalidValue(try sut.quantityQuery(type: .stepCount, unit: unit) { _, _ in })
            assertInvalidValue(try sut.statisticsQuery(type: .stepCount, unit: unit) { _, _ in })
            assertInvalidValue(
                try sut.statisticsCollectionQuery(
                    type: .stepCount,
                    unit: unit,
                    anchorDate: anchorDate,
                    enumerateFrom: anchorDate,
                    enumerateTo: anchorDate,
                    intervalComponents: DateComponents(day: 1)
                ) { _, _ in }
            )
        }
    }
    func testQueriesAcceptEveryUnitGrammarForm() throws {
        let units: [QuantityType: [String]] = [
            .bloodGlucose: ["mg/dL", "mmol<180.1558>/L", "mg/dl"],
            .vo2Max: ["ml/kg*min", "mL/(kg.min)", "mL/kg·min"],
            .bloodPressureSystolic: ["mmHg", "kg/(m.s^2)", "kPa", "kg.m^-1.s^-2"],
            .heartRate: ["count/min", "Hz"],
            .bodyTemperature: ["degC", "degF", "K"],
            .dietaryWater: ["fl_oz_us", "cup_imp", "mcL"],
            .bodyMassIndex: ["count"],
            .bodyFatPercentage: ["%"]
        ]
        for (type, typeUnits) in units {
            for unit in typeUnits {
                XCTAssertNoThrow(try sut.quantityQuery(type: type, unit: unit) { _, _ in }, unit)
            }
        }
    }
}
// MARK: - Statistics batches
extension HealthKitReaderTests {
}
#if os(iOS)
// MARK: - Health records
extension HealthKitReaderTests {
    func testSupportsHealthRecords() throws {
        let manager = HealthKitReporter().manager
        XCTAssertEqual(manager.supportsHealthRecords(), HKHealthStore().supportsHealthRecords())
    }
}
#endif
