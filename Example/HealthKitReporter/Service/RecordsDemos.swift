//
//  RecordsDemos.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import HealthKit
import HealthKitReporter

/// Health records, wellbeing and medications
final class RecordsDemos: DemoPerformer {
    private let reporter: HealthKitReporter

    init(reporter: HealthKitReporter) {
        self.reporter = reporter
    }

    func publisher(for row: DemoRow) -> AnyPublisher<String, Error> {
        reporter.publisher { [unowned self] completion in
            let reader = reporter.reader
            let execute = reporter.manager.executeQuery
            switch row {
            case .supportsHealthRecords:
                completion(.success(reporter.manager.supportsHealthRecords() ? "Supported" : "Not supported on this device"))
            case .clinicalRecordQuery:
                guard reporter.manager.supportsHealthRecords() else {
                    throw HealthKitError.notAvailable("Health records are not supported on this device")
                }
                let types = ClinicalType.allCases.filter { $0.original != nil }
                reporter.countEveryType(types, completion: completion) { type, done in
                    try reader.clinicalRecordQuery(type: type) { records, _ in done(records) }
                }
            case .verifiableClinicalRecordQuery:
                execute(
                    reader.verifiableClinicalRecordQuery(
                        recordTypes: ["https://smarthealth.cards#immunization"]
                    ) { records, error in
                        completion(error.map { .failure($0) } ?? .success(records.summary("verifiable records")))
                    }
                )
            case .cdaDocumentQuery:
                var documents = [CDADocument]()
                execute(
                    try reader.cdaDocumentQuery { batch, done, error in
                        documents += batch
                        guard done else {
                            return
                        }
                        completion(error.map { .failure($0) } ?? .success(documents.summary("CDA documents")))
                    }
                )
            case .visionPrescriptionQuery:
                guard #available(iOS 16.0, *) else {
                    throw HealthKitError.notAvailable("Vision prescriptions need iOS 16")
                }
                execute(
                    try reader.visionPrescriptionQuery { prescriptions, error in
                        completion(error.map { .failure($0) } ?? .success(prescriptions.summary("prescriptions")))
                    }
                )
            case .audiogramQuery:
                execute(
                    try reader.audiogramQuery { audiograms, error in
                        completion(error.map { .failure($0) } ?? .success(audiograms.summary("audiograms")))
                    }
                )
            default:
                try wellbeing(row, completion: completion)
            }
        }
    }

    private func wellbeing(_ row: DemoRow, completion: @escaping DemoCompletion) throws {
        let reader = reporter.reader
        let execute = reporter.manager.executeQuery
        switch row {
        case .stateOfMindQuery, .scoredAssessmentQuery, .workoutEffortRelationshipQuery:
            guard #available(iOS 18.0, *) else {
                throw HealthKitError.notAvailable("\(row.title) needs iOS 18")
            }
            if row == .stateOfMindQuery {
                execute(
                    try reader.stateOfMindQuery { states, error in
                        completion(error.map { .failure($0) } ?? .success(states.summary("states of mind")))
                    }
                )
            } else if row == .scoredAssessmentQuery {
                reporter.countEveryType(ScoredAssessmentType.allCases, completion: completion) { type, done in
                    try reader.scoredAssessmentQuery(type: type) { assessments, _ in done(assessments) }
                }
            } else {
                execute(
                    reader.workoutEffortRelationshipQuery { relationships, _, error in
                        completion(error.map { .failure($0) } ?? .success(relationships.summary("workouts with effort")))
                    }
                )
            }
        case .userAnnotatedMedicationQuery, .medicationDoseEventQuery:
            guard #available(iOS 26.0, *) else {
                throw HealthKitError.notAvailable("Medications need iOS 26")
            }
            execute(
                reader.userAnnotatedMedicationQuery { medications, error in
                    guard row == .medicationDoseEventQuery else {
                        completion(error.map { .failure($0) } ?? .success(medications.summary("medications")))
                        return
                    }
                    do {
                        let medication = medications.first?.medication
                        execute(
                            try reader.medicationDoseEventQuery(
                                medicationConceptIdentifier: medication?.identifier
                            ) { doses, error in
                                let name = medication?.displayText ?? "every medication"
                                completion(error.map { .failure($0) } ?? .success(doses.summary("doses of \(name)")))
                            }
                        )
                    } catch {
                        completion(.failure(error))
                    }
                }
            )
        default:
            throw HealthKitError.invalidOption("\(row) is not a records or wellbeing demo")
        }
    }
}
