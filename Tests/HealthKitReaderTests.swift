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
    private enum InvalidSampleType: SampleType {
        case characteristic
        case unavailable

        var identifier: String? {
            return original?.identifier
        }
        var original: HKObjectType? {
            switch self {
            case .characteristic:
                return HKObjectType.characteristicType(forIdentifier: .bloodType)
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

    func testQuantityQueryDefaults() throws {
        let query = try sut.quantityQuery(type: .stepCount, unit: "count") { _, _ in }
        XCTAssertEqual(query.objectType?.identifier, "HKQuantityTypeIdentifierStepCount")
        assertDefaults(query)
    }
    func testQuantityQuery() throws {
        let query = try sut.quantityQuery(
            type: .stepCount,
            unit: "count",
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: 10
        ) { _, _ in }
        assertCustom(query)
    }
    func testCategoryQuery() throws {
        let defaults = try sut.categoryQuery(type: .sleepAnalysis) { _, _ in }
        XCTAssertEqual(defaults.objectType?.identifier, "HKCategoryTypeIdentifierSleepAnalysis")
        assertDefaults(defaults)
        let query = try sut.categoryQuery(
            type: .sleepAnalysis,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: 10
        ) { _, _ in }
        assertCustom(query)
    }
    func testWorkoutQuery() throws {
        let defaults = try sut.workoutQuery { _, _ in }
        XCTAssertEqual(defaults.objectType?.identifier, "HKWorkoutTypeIdentifier")
        assertDefaults(defaults)
        let query = try sut.workoutQuery(
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: 10
        ) { _, _ in }
        assertCustom(query)
    }
    func testCorrelationSampleQuery() throws {
        let defaults: SampleQuery = try sut.correlationQuery(type: .bloodPressure) { _, _ in }
        XCTAssertEqual(defaults.objectType?.identifier, "HKCorrelationTypeIdentifierBloodPressure")
        assertDefaults(defaults)
        let query = try sut.correlationQuery(
            type: .bloodPressure,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: 10
        ) { _, _ in }
        assertCustom(query)
    }
    func testCorrelationQuery() throws {
        let query = try sut.correlationQuery(
            type: .bloodPressure,
            predicate: predicate,
            typePredicates: ["HKQuantityTypeIdentifierBloodPressureSystolic": predicate]
        ) { _, _ in }
        XCTAssertEqual(query.objectType?.identifier, "HKCorrelationTypeIdentifierBloodPressure")
        XCTAssertEqual(query.predicate, predicate)
        XCTAssertEqual(query.samplePredicates?.count, 1)
        let systolic = try XCTUnwrap(QuantityType.bloodPressureSystolic.original as? HKSampleType)
        XCTAssertEqual(query.samplePredicates?[systolic], predicate)
    }
    func testElectrocardiogramQuery() throws {
        let defaults = try sut.electrocardiogramQuery { _, _ in }
        XCTAssertEqual(defaults.objectType?.identifier, "HKDataTypeIdentifierElectrocardiogram")
        assertDefaults(defaults)
        let query = try sut.electrocardiogramQuery(
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: 10,
            withVoltageMeasurements: true
        ) { _, _ in }
        assertCustom(query)
    }
    func testVisionPrescriptionQuery() throws {
        guard #available(iOS 16.0, *) else {
            throw XCTSkip("Vision prescriptions require iOS 16")
        }
        let defaults = try sut.visionPrescriptionQuery { _, _ in }
        XCTAssertEqual(defaults.objectType?.identifier, "HKVisionPrescriptionTypeIdentifier")
        assertDefaults(defaults)
        let query = try sut.visionPrescriptionQuery(
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: 10
        ) { _, _ in }
        assertCustom(query)
    }
    func testHeartbeatSeriesQuery() throws {
        let defaults = try sut.heartbeatSeriesQuery { _, _ in }
        XCTAssertEqual(defaults.objectType?.identifier, "HKDataTypeIdentifierHeartbeatSeries")
        assertDefaults(defaults)
        let query = try sut.heartbeatSeriesQuery(
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: 10
        ) { _, _ in }
        assertCustom(query)
    }
    func testWorkoutRouteQuery() throws {
        let defaults = try sut.workoutRouteQuery { _, _ in }
        XCTAssertEqual(defaults.objectType?.identifier, "HKWorkoutRouteTypeIdentifier")
        assertDefaults(defaults)
        let query = try sut.workoutRouteQuery(
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: 10
        ) { _, _ in }
        assertCustom(query)
    }
    func testStatisticsQuery() throws {
        let cumulative = try sut.statisticsQuery(
            type: .stepCount,
            unit: "count",
            predicate: predicate
        ) { _, _ in }
        XCTAssertEqual(cumulative.objectType?.identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(cumulative.predicate, predicate)
        let discrete = try sut.statisticsQuery(type: .heartRate, unit: "count/min") { _, _ in }
        XCTAssertEqual(discrete.objectType?.identifier, "HKQuantityTypeIdentifierHeartRate")
        XCTAssertEqual(discrete.predicate, .allSamples)
    }
    func testStatisticsCollectionQuery() throws {
        let anchorDate = Date(timeIntervalSince1970: 1626884800)
        let intervalComponents = DateComponents(day: 1)
        let cumulative = try sut.statisticsCollectionQuery(
            type: .stepCount,
            unit: "count",
            quantitySamplePredicate: predicate,
            anchorDate: anchorDate,
            enumerateFrom: anchorDate,
            enumerateTo: anchorDate.addingTimeInterval(86400),
            intervalComponents: intervalComponents,
            monitorUpdates: true
        ) { _, _ in }
        XCTAssertEqual(cumulative.objectType?.identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(cumulative.predicate, predicate)
        XCTAssertEqual(cumulative.anchorDate, anchorDate)
        XCTAssertEqual(cumulative.intervalComponents, intervalComponents)
        XCTAssertEqual(cumulative.options, .cumulativeSum)
        XCTAssertNotNil(cumulative.initialResultsHandler)
        XCTAssertNotNil(cumulative.statisticsUpdateHandler)
        let discrete = try sut.statisticsCollectionQuery(
            type: .heartRate,
            unit: "count/min",
            anchorDate: anchorDate,
            enumerateFrom: anchorDate,
            enumerateTo: anchorDate.addingTimeInterval(86400),
            intervalComponents: intervalComponents
        ) { _, _ in }
        XCTAssertEqual(discrete.options, [.discreteAverage, .discreteMin, .discreteMax, .mostRecent])
        XCTAssertEqual(discrete.predicate, .allSamples)
        XCTAssertNil(discrete.statisticsUpdateHandler)
    }
    func testQueryActivitySummary() throws {
        let defaults = sut.queryActivitySummary { _, _ in }
        XCTAssertNil(defaults.predicate)
        XCTAssertNil(defaults.updateHandler)
        let start = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2021, month: 7, day: 1)
        let end = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2021, month: 7, day: 31)
        let predicate = NSPredicate.activitySummaryPredicateBetween(start: start, end: end)
        let query = sut.queryActivitySummary(
            predicate: predicate,
            monitorUpdates: true
        ) { _, _ in }
        XCTAssertEqual(query.predicate, predicate)
        XCTAssertNotNil(query.updateHandler)
        XCTAssertNotNil(NSPredicate.activitySummaryPredicate(dateComponents: start))
    }
    func testAnchoredObjectQuery() throws {
        let defaults = try sut.anchoredObjectQuery(type: QuantityType.stepCount) { _, _, _, _, _ in }
        XCTAssertEqual(defaults.objectType?.identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(defaults.predicate, .allSamples)
        XCTAssertNil(defaults.updateHandler)
        let query = try sut.anchoredObjectQuery(
            type: CategoryType.sleepAnalysis,
            predicate: predicate,
            anchor: nil,
            limit: 10
        ) { _, _, _, _, _ in }
        XCTAssertEqual(query.objectType?.identifier, "HKCategoryTypeIdentifierSleepAnalysis")
        XCTAssertEqual(query.predicate, predicate)
        XCTAssertNil(query.updateHandler)
        let monitoring = try sut.anchoredObjectQuery(
            type: CategoryType.sleepAnalysis,
            monitorUpdates: true
        ) { _, _, _, _, _ in }
        XCTAssertNotNil(monitoring.updateHandler)
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
    func testSourceQuery() throws {
        let defaults = try sut.sourceQuery(type: QuantityType.stepCount) { _, _ in }
        XCTAssertEqual(defaults.objectType?.identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(defaults.predicate, .allSamples)
        let query = try sut.sourceQuery(type: WorkoutType.workoutType, predicate: predicate) { _, _ in }
        XCTAssertEqual(query.objectType?.identifier, "HKWorkoutTypeIdentifier")
        XCTAssertEqual(query.predicate, predicate)
    }
    func testSourceQueryWithInvalidType() throws {
        for type in [InvalidSampleType.characteristic, .unavailable] {
            assertInvalidType(try sut.sourceQuery(type: type) { _, _ in })
        }
    }

    private func assertDefaults(
        _ query: SampleQuery,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(query.predicate, .allSamples, file: file, line: line)
        XCTAssertEqual(query.limit, HKObjectQueryNoLimit, file: file, line: line)
        XCTAssertEqual(
            query.sortDescriptors,
            [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)],
            file: file,
            line: line
        )
    }
    private func assertCustom(
        _ query: SampleQuery,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(query.predicate, predicate, file: file, line: line)
        XCTAssertEqual(query.limit, 10, file: file, line: line)
        XCTAssertEqual(query.sortDescriptors, sortDescriptors, file: file, line: line)
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
    func testStatisticsCollectionBatchQuery() throws {
        let anchorDate = Date(timeIntervalSince1970: 1626884800)
        let monitoring = try sut.statisticsCollectionQuery(
            type: .stepCount,
            unit: "count",
            quantitySamplePredicate: predicate,
            anchorDate: anchorDate,
            enumerateFrom: anchorDate,
            intervalComponents: DateComponents(day: 1),
            monitorUpdates: true
        ) { (_: [Statistics], _) in }
        XCTAssertEqual(monitoring.objectType?.identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(monitoring.predicate, predicate)
        XCTAssertEqual(monitoring.anchorDate, anchorDate)
        XCTAssertEqual(monitoring.options, .cumulativeSum)
        XCTAssertNotNil(monitoring.initialResultsHandler)
        XCTAssertNotNil(monitoring.statisticsUpdateHandler)
        let once = try sut.statisticsCollectionQuery(
            type: .heartRate,
            unit: "count/min",
            anchorDate: anchorDate,
            enumerateFrom: anchorDate,
            enumerateTo: anchorDate.addingTimeInterval(86400),
            intervalComponents: DateComponents(hour: 1)
        ) { (_: [Statistics], _) in }
        XCTAssertEqual(once.options, [.discreteAverage, .discreteMin, .discreteMax, .mostRecent])
        XCTAssertNil(once.statisticsUpdateHandler)
        assertInvalidValue(
            try sut.statisticsCollectionQuery(
                type: .stepCount,
                unit: "kg",
                anchorDate: anchorDate,
                enumerateFrom: anchorDate,
                intervalComponents: DateComponents(day: 1)
            ) { (_: [Statistics], _) in }
        )
    }
}
// MARK: - Health records
extension HealthKitReaderTests {
    func testClinicalRecordQuery() throws {
        for type in ClinicalType.allCases {
            let defaults = try sut.clinicalRecordQuery(type: type) { _, _ in }
            XCTAssertEqual(defaults.objectType?.identifier, type.identifier)
            assertDefaults(defaults)
        }
        let query = try sut.clinicalRecordQuery(
            type: .coverageRecord,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: 10
        ) { _, _ in }
        assertCustom(query)
    }
    func testVerifiableClinicalRecordQuery() throws {
        let all = sut.verifiableClinicalRecordQuery(
            recordTypes: ["https://smarthealth.cards#immunization"]
        ) { _, _ in }
        XCTAssertEqual(all.recordTypes, ["https://smarthealth.cards#immunization"])
        XCTAssertNil(all.predicate)
        let smartHealthCards = sut.verifiableClinicalRecordQuery(
            recordTypes: ["https://smarthealth.cards#immunization"],
            sourceTypes: ["https://smarthealth.cards"],
            predicate: predicate
        ) { _, _ in }
        if #available(iOS 15.4, *) {
            XCTAssertEqual(smartHealthCards.sourceTypes.map(\.rawValue), ["https://smarthealth.cards"])
        }
        XCTAssertEqual(smartHealthCards.predicate, predicate)
    }
    func testSupportsHealthRecords() throws {
        let manager = HealthKitReporter().manager
        XCTAssertEqual(manager.supportsHealthRecords(), HKHealthStore().supportsHealthRecords())
    }
}
