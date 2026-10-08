//
//  QueryHandleTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

/// Every query the reader and observer build is a **QueryHandle** the manager can run and stop
class QueryHandleTests: XCTestCase {
    private let reporter = HealthKitReporter()
    private var lastWeek: NSPredicate {
        return NSPredicate.samplesPredicate(
            startDate: Date(timeIntervalSince1970: 1626884800),
            endDate: Date(timeIntervalSince1970: 1627489600),
            options: .strictEndDate
        )
    }

    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    func testSampleQueriesRunAndStop() throws {
        let reader = reporter.reader
        let steps = [QueryDescriptor(type: QuantityType.stepCount)]
        assertRunAndStop([
            try reader.quantityQuery(type: .stepCount, unit: "count", limit: 1) { _, _ in },
            try reader.categoryQuery(type: .sleepAnalysis) { _, _ in },
            try reader.workoutQuery { _, _ in },
            try reader.sampleQuery(type: QuantityType.heartRate) { _, _, _ in },
            try reader.sampleQuery(descriptors: steps) { _, _, _ in },
            try reader.correlationQuery(type: .bloodPressure) { _, _ in },
            try reader.correlationQuery(
                type: .bloodPressure,
                typePredicates: ["HKQuantityTypeIdentifierBloodPressureSystolic": lastWeek]
            ) { _, _ in },
            try reader.anchoredObjectQuery(
                type: QuantityType.heartRate,
                monitorUpdates: true
            ) { _, _, _, _, _ in },
            try reader.anchoredObjectQuery(descriptors: steps) { _, _, _, _, _ in },
            try reader.sourceQuery(type: QuantityType.stepCount) { _, _ in },
            reader.queryActivitySummary(monitorUpdates: true) { _, _ in }
        ])
    }
    func testStatisticsAndSeriesQueriesRunAndStop() throws {
        let reader = reporter.reader
        let anchorDate = Date(timeIntervalSince1970: 1626884800)
        assertRunAndStop([
            try reader.statisticsQuery(type: .stepCount, unit: "count", separateBySource: true) { _, _ in },
            try reader.statisticsCollectionQuery(
                type: .stepCount,
                unit: "count",
                anchorDate: anchorDate,
                enumerateFrom: anchorDate,
                enumerateTo: anchorDate.addingTimeInterval(86_400),
                intervalComponents: DateComponents(day: 1),
                monitorUpdates: true
            ) { (_: Statistics?, _) in },
            try reader.statisticsCollectionQuery(
                type: .heartRate,
                unit: "count/min",
                anchorDate: anchorDate,
                enumerateFrom: anchorDate,
                intervalComponents: DateComponents(day: 1),
                monitorUpdates: true
            ) { (_: [Statistics], _) in },
            try reader.electrocardiogramQuery(withVoltageMeasurements: true) { _, _ in },
            try reader.heartbeatSeriesQuery { _, _ in },
            try reader.workoutRouteQuery { _, _ in },
            try reader.quantitySeriesQuery(type: .stepCount, unit: "count") { _, _ in }
        ])
    }
    func testRecordAndWellbeingQueriesRunAndStop() throws {
        let reader = reporter.reader
        var handles = [try reader.audiogramQuery { _, _ in }]
        if #available(iOS 16.0, watchOS 9.0, *) {
            handles.append(try reader.visionPrescriptionQuery { _, _ in })
        }
        if #available(iOS 18.0, watchOS 11.0, *) {
            handles.append(try reader.stateOfMindQuery { _, _ in })
            handles.append(try reader.scoredAssessmentQuery(type: .gad7) { _, _ in })
            handles.append(reader.workoutEffortRelationshipQuery(mostRelevant: true) { _, _, _ in })
        }
        if #available(iOS 26.0, watchOS 26.0, *) {
            handles.append(try reader.medicationDoseEventQuery { _, _ in })
            handles.append(reader.userAnnotatedMedicationQuery { _, _ in })
        }
        #if os(iOS)
        handles.append(try reader.clinicalRecordQuery(type: .allergyRecord) { _, _ in })
        handles.append(try reader.cdaDocumentQuery { _, _, _ in })
        let immunizations = ["https://smarthealth.cards#immunization"]
        handles.append(reader.verifiableClinicalRecordQuery(recordTypes: immunizations) { _, _ in })
        #endif
        assertRunAndStop(handles)
    }
    func testObserverQueriesRunAndStop() throws {
        let observer = reporter.observer
        assertRunAndStop([
            try observer.observerQuery(type: QuantityType.stepCount) { _, _, _ in },
            try observer.observerQuery(type: CategoryType.sleepAnalysis) { _, _, _, completion in
                completion()
            },
            try observer.observerQuery(
                descriptors: [QueryDescriptor(type: QuantityType.stepCount)]
            ) { _, _, _, completion in
                completion()
            }
        ])
    }
    func testHandlesAreEqualByQuery() throws {
        let handle = try reporter.reader.workoutQuery { _, _ in }
        XCTAssertEqual(handle, handle)
        XCTAssertNotEqual(handle, try reporter.reader.workoutQuery { _, _ in })
    }
    func testAnchorIsCodableData() throws {
        let sut = Anchor(data: Data([1, 2, 3]))
        let data = try XCTUnwrap(sut.encoded().data(using: .utf8))
        let decoded = try JSONDecoder().decode(Anchor.self, from: data)
        XCTAssertEqual(decoded, sut)
        XCTAssertEqual(try json(["anchor": sut]) as? [String: String], ["anchor": "AQID"])
    }
    func testSamplePredicateOptions() throws {
        let options: SamplePredicateOptions = [.strictStartDate, .strictEndDate]
        XCTAssertTrue(options.contains(.strictStartDate))
        XCTAssertEqual(SamplePredicateOptions.strictEndDate.rawValue, 2)
        XCTAssertNotNil(NSPredicate.samplesPredicate(startDate: Date(), endDate: Date(), options: []))
    }

    private func assertRunAndStop(
        _ handles: [QueryHandle],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertFalse(handles.isEmpty, file: file, line: line)
        for handle in handles {
            reporter.manager.executeQuery(handle)
            reporter.manager.stopQuery(handle)
        }
    }
}
