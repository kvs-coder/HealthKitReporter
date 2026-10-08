//
//  QueryResultsTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKitReporter

/// Every query reports back through its handler. The test host has no HealthKit entitlement,
/// so HealthKit answers with an error and the handler gets empty results
class QueryResultsTests: XCTestCase {
    private let reporter = HealthKitReporter()
    private let anchorDate = Date(timeIntervalSince1970: 1626884800)

    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    func testSampleQueriesReportErrors() throws {
        let reader = reporter.reader
        try assertReports { done in
            try reader.quantityQuery(type: .stepCount, unit: "count") { done($0.isEmpty, $1) }
        }
        try assertReports { done in try reader.categoryQuery(type: .sleepAnalysis) { done($0.isEmpty, $1) } }
        try assertReports { done in try reader.workoutQuery { done($0.isEmpty, $1) } }
        try assertReports { done in
            try reader.sampleQuery(type: QuantityType.heartRate) { done($1.isEmpty, $2) }
        }
        try assertReports { done in
            try reader.sampleQuery(descriptors: [QueryDescriptor(type: QuantityType.stepCount)]) {
                done($1.isEmpty, $2)
            }
        }
        try assertReports { done in
            try reader.correlationQuery(type: .bloodPressure) { done($0.isEmpty, $1) }
        }
        try assertReports { done in
            try reader.correlationQuery(
                type: .food,
                typePredicates: ["HKQuantityTypeIdentifierDietaryEnergyConsumed": .allSamples]
            ) { done($0.isEmpty, $1) }
        }
        try assertReports { done in
            try reader.sourceQuery(type: QuantityType.stepCount) { done($0.isEmpty, $1) }
        }
        try assertReports { done in reader.queryActivitySummary { done($0.isEmpty, $1) } }
    }
    func testAnchoredQueriesReportErrors() throws {
        let reader = reporter.reader
        try assertReports { done in
            try reader.anchoredObjectQuery(type: QuantityType.stepCount) { _, samples, deleted, _, error in
                done(samples.isEmpty && deleted.isEmpty, error)
            }
        }
        try assertReports { done in
            try reader.anchoredObjectQuery(
                descriptors: [QueryDescriptor(type: QuantityType.stepCount)],
                anchor: Anchor(data: Data())
            ) { _, samples, _, _, error in
                done(samples.isEmpty, error)
            }
        }
    }
    func testStatisticsQueriesReportErrors() throws {
        let reader = reporter.reader
        try assertReports { done in
            try reader.statisticsQuery(type: .stepCount, unit: "count", separateBySource: true) {
                done($0 == nil, $1)
            }
        }
        try assertReports { done in
            try reader.statisticsCollectionQuery(
                type: .stepCount,
                unit: "count",
                anchorDate: anchorDate,
                enumerateFrom: anchorDate,
                enumerateTo: anchorDate.addingTimeInterval(86_400),
                intervalComponents: DateComponents(day: 1)
            ) { (statistics: Statistics?, error) in
                done(statistics == nil, error)
            }
        }
        try assertReports { done in
            try reader.statisticsCollectionQuery(
                type: .heartRate,
                unit: "count/min",
                anchorDate: anchorDate,
                enumerateFrom: anchorDate,
                intervalComponents: DateComponents(day: 1)
            ) { (statistics: [Statistics], error) in
                done(statistics.isEmpty, error)
            }
        }
    }
    func testSeriesQueriesReportErrors() throws {
        let reader = reporter.reader
        try assertReports { done in
            try reader.electrocardiogramQuery(withVoltageMeasurements: true) { done($0.isEmpty, $1) }
        }
        try assertReports { done in try reader.electrocardiogramQuery { done($0.isEmpty, $1) } }
        try assertReports { done in try reader.heartbeatSeriesQuery { done($0.isEmpty, $1) } }
        try assertReports { done in try reader.workoutRouteQuery { done($0.isEmpty, $1) } }
        try assertReports { done in
            try reader.quantitySeriesQuery(type: .stepCount, unit: "count") { done($0.isEmpty, $1) }
        }
    }
    func testRecordAndWellbeingQueriesReportErrors() throws {
        let reader = reporter.reader
        try assertReports { done in try reader.audiogramQuery { done($0.isEmpty, $1) } }
        if #available(iOS 16.0, watchOS 9.0, *) {
            try assertReports { done in try reader.visionPrescriptionQuery { done($0.isEmpty, $1) } }
        }
        if #available(iOS 18.0, watchOS 11.0, *) {
            try assertReports { done in try reader.stateOfMindQuery { done($0.isEmpty, $1) } }
            try assertReports { done in
                try reader.scoredAssessmentQuery(type: .phq9) { done($0.isEmpty, $1) }
            }
            try assertReports { done in
                reader.workoutEffortRelationshipQuery { relationships, _, error in
                    done(relationships.isEmpty, error)
                }
            }
        }
        if #available(iOS 26.0, watchOS 26.0, *) {
            try assertReports { done in try reader.medicationDoseEventQuery { done($0.isEmpty, $1) } }
            try assertReports { done in reader.userAnnotatedMedicationQuery { done($0.isEmpty, $1) } }
        }
        #if os(iOS)
        try assertReports { done in
            try reader.clinicalRecordQuery(type: .labResultRecord) { done($0.isEmpty, $1) }
        }
        try assertReports { done in
            try reader.cdaDocumentQuery { documents, _, error in done(documents.isEmpty, error) }
        }
        #endif
    }
    func testObserverQueriesReportErrors() throws {
        let observer = reporter.observer
        try assertReports { done in
            try observer.observerQuery(type: QuantityType.stepCount) { _, _, error in done(true, error) }
        }
        try assertReports { done in
            try observer.observerQuery(type: QuantityType.stepCount) { _, _, error, completion in
                completion()
                done(true, error)
            }
        }
        try assertReports { done in
            try observer.observerQuery(
                descriptors: [QueryDescriptor(type: CategoryType.sleepAnalysis)]
            ) { _, _, error, completion in
                completion()
                done(true, error)
            }
        }
    }

    /// Runs the query, waits for its first callback and checks it reported an error with empty results
    private func assertReports(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ makeQuery: (@escaping (Bool, Error?) -> Void) throws -> QueryHandle
    ) throws {
        let expectation = expectation(description: "results")
        expectation.assertForOverFulfill = false
        var reported: (empty: Bool, error: Error?)?
        let query = try makeQuery { empty, error in
            if reported == nil {
                reported = (empty, error)
            }
            expectation.fulfill()
        }
        reporter.manager.executeQuery(query)
        wait(for: [expectation], timeout: 30)
        reporter.manager.stopQuery(query)
        let result = try XCTUnwrap(reported, file: file, line: line)
        XCTAssertTrue(result.empty, file: file, line: line)
        XCTAssertNotNil(result.error, file: file, line: line)
    }
}
