//
//  WriterDemos.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import HealthKit
import HealthKitReporter

/// Reports a status callback as the demo result
private func status(_ success: Bool, _ error: Error?, _ message: String, _ completion: DemoCompletion) {
    completion(success ? .success(message) : .failure(error ?? HealthKitError.unknown()))
}

/// Every payload the library writes, plus deleting the demo's own data
final class WriterDemos: DemoPerformer {
    private let reporter: HealthKitReporter
    private let samples = DemoSamples(marker: "hkr-demo-")

    init(reporter: HealthKitReporter) {
        self.reporter = reporter
    }

    func publisher(for row: DemoRow) -> AnyPublisher<String, Error> {
        reporter.publisher { [unowned self] completion in
            let now = Date()
            switch row {
            case .saveQuantity:
                save([samples.quantity(.stepCount, value: 1_200, unit: "count", start: now.addingTimeInterval(-3_600), end: now)], completion)
            case .saveCategory:
                let night = Calendar.current.startOfDay(for: now)
                save([samples.category(.sleepAnalysis, value: 0, start: night.addingTimeInterval(-7_200), end: night.addingTimeInterval(21_600))], completion)
            case .saveCorrelation:
                save([samples.bloodPressure(systolic: 118, diastolic: 76, at: now), samples.food(kilocalories: 450, protein: 25, at: now)], completion)
            case .saveWorkout:
                save([samples.workout(start: now.addingTimeInterval(-3_600), minutes: 30)], completion)
            case .saveWorkoutWithBuilder:
                saveWithBuilder(completion: completion)
            case .addQuantity, .addCategory:
                try addToLatestWorkout(row, completion: completion)
            case .saveQuantitySeries:
                saveQuantitySeries(completion: completion)
            case .saveHeartbeatSeries:
                reporter.writer.saveHeartbeatSeries(heartbeatSeries(at: now)) { status($0, $1, "Heartbeat series saved", completion) }
            case .saveAudiogram:
                save([audiogram(at: now)], completion)
            case .delete:
                deleteAfterSaving(completion: completion)
            case .deleteObjects:
                deleteOwnSteps(completion: completion)
            default:
                try writeRecent(row, now: now, completion: completion)
            }
        }
    }

    /// Payloads of iOS 16+ APIs
    private func writeRecent(_ row: DemoRow, now: Date, completion: @escaping DemoCompletion) throws {
        switch row {
        case .saveVisionPrescription:
            guard #available(iOS 16.0, *) else {
                throw HealthKitError.notAvailable("Vision prescriptions need iOS 16")
            }
            save([glasses(at: now)], completion)
        case .saveCDADocument:
            save([try cdaDocument(at: now)], completion)
        case .saveStateOfMind, .saveScoredAssessment, .relateWorkoutEffort, .unrelateWorkoutEffort:
            guard #available(iOS 18.0, *) else {
                throw HealthKitError.notAvailable("\(row.title) needs iOS 18")
            }
            switch row {
            case .saveStateOfMind:
                save([stateOfMind(at: now)], completion)
            case .saveScoredAssessment:
                save(assessments(at: now), completion)
            default:
                try effort(relate: row == .relateWorkoutEffort, completion: completion)
            }
        default:
            throw HealthKitError.invalidOption("\(row) is not a write demo")
        }
    }

    private func save(_ payloads: [Sample], _ completion: @escaping DemoCompletion) {
        let group = DispatchGroup()
        let lock = NSLock()
        var lines = [String]()
        for payload in payloads {
            group.enter()
            reporter.writer.save(sample: payload) { success, error in
                lock.lock()
                lines.append("\(type(of: payload)): \(success ? "saved" : error?.localizedDescription ?? "failed")")
                lock.unlock()
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            completion(.success(lines.sorted().joined(separator: "\n")))
        }
    }

    private func saveWithBuilder(completion: @escaping DemoCompletion) {
        let start = Date().addingTimeInterval(-7_200)
        let heartRates = (0..<6).map {
            samples.quantity(.heartRate, value: 120 + Double($0 * 5), unit: "count/min", start: start.addingTimeInterval(Double($0) * 300))
        }
        let route = (0..<5).map { index in
            WorkoutRoute.Location(
                latitude: 52.5200 + Double(index) * 0.001,
                longitude: 13.4050,
                altitude: 34,
                course: 0,
                courseAccuracy: nil,
                floor: nil,
                horizontalAccuracy: 5,
                speed: 3,
                speedAccuracy: nil,
                timestamp: start.addingTimeInterval(Double(index) * 300).timeIntervalSince1970,
                verticalAccuracy: 3
            )
        }
        reporter.writer.saveWorkout(samples.workout(start: start, minutes: 30), samples: heartRates, route: route) { workout, error in
            completion(workout.map { .success("Saved through the builder:\n\($0.json)") } ?? .failure(error ?? HealthKitError.unknown()))
        }
    }
    /// The latest stored workout, which samples are added to and effort is related to
    private func latestWorkout(_ completion: @escaping (Result<Workout, Error>) -> Void) throws {
        let query = try reporter.reader.workoutQuery(limit: 1) { workouts, error in
            guard let workout = workouts.first else {
                completion(.failure(error ?? HealthKitError.invalidValue("Save a workout first")))
                return
            }
            completion(.success(workout))
        }
        reporter.manager.executeQuery(query)
    }
    private func addToLatestWorkout(_ row: DemoRow, completion: @escaping DemoCompletion) throws {
        try latestWorkout { [unowned self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let workout):
                let start = Date(timeIntervalSince1970: workout.startTimestamp)
                let end = Date(timeIntervalSince1970: workout.endTimestamp)
                let message = "Added to the workout of \(start.formatted())"
                if row == .addQuantity {
                    let energy = samples.quantity(.activeEnergyBurned, value: 120, unit: "kcal", start: start, end: end)
                    reporter.writer.addQuantity([energy], from: nil, to: workout) { status($0, $1, message, completion) }
                } else {
                    let mindful = samples.category(.mindfulSession, value: 0, start: start, end: end)
                    reporter.writer.addCategory([mindful], from: nil, to: workout) { status($0, $1, message, completion) }
                }
            }
        }
    }
    private func saveQuantitySeries(completion: @escaping DemoCompletion) {
        let start = Date().addingTimeInterval(-600)
        let values = (0..<10).map { (minute: Int) -> QuantitySeriesValue in
            let offset = Double(minute) * 60
            return QuantitySeriesValue(
                value: Double(40 + minute * 3),
                unit: "count",
                startTimestamp: start.addingTimeInterval(offset).timeIntervalSince1970,
                endTimestamp: start.addingTimeInterval(offset + 60).timeIntervalSince1970
            )
        }
        reporter.writer.saveQuantitySeries(type: .stepCount, values: values, metadata: samples.metadata) {
            status($0, $1, "Series of \(values.count) step counts saved", completion)
        }
    }
    private func heartbeatSeries(at date: Date) -> HeartbeatSeries {
        let beats = (0..<20).map {
            HeartbeatSeries.Measurement(timeSinceSeriesStart: Double($0) * 0.8, precededByGap: false, done: $0 == 19)
        }
        return HeartbeatSeries(
            identifier: SeriesType.heartbeatSeries.identifier ?? "",
            startTimestamp: date.addingTimeInterval(-60).timeIntervalSince1970,
            endTimestamp: date.timeIntervalSince1970,
            device: nil,
            sourceRevision: samples.sourceRevision,
            harmonized: HeartbeatSeries.Harmonized(count: beats.count, measurements: beats, metadata: samples.metadata)
        )
    }
    private func audiogram(at date: Date) -> Audiogram {
        let points = [250.0, 500, 1_000, 2_000, 4_000, 8_000].enumerated().map {
            Audiogram.SensitivityPoint(
                frequency: $1,
                leftEarSensitivity: 10 + Double($0) * 2,
                rightEarSensitivity: 12 + Double($0) * 2
            )
        }
        return Audiogram(
            identifier: AudiogramType.audiogram.identifier ?? "",
            startTimestamp: date.addingTimeInterval(-600).timeIntervalSince1970,
            endTimestamp: date.timeIntervalSince1970,
            device: nil,
            sourceRevision: samples.sourceRevision,
            harmonized: Audiogram.Harmonized(sensitivityPoints: points, metadata: samples.metadata)
        )
    }
    @available(iOS 16.0, *)
    private func glasses(at date: Date) -> VisionPrescription {
        return VisionPrescription(
            identifier: VisionPrescriptionType.visionPrescription.identifier ?? "",
            startTimestamp: date.timeIntervalSince1970,
            endTimestamp: date.timeIntervalSince1970,
            device: nil,
            sourceRevision: samples.sourceRevision,
            harmonized: VisionPrescription.Harmonized(
                dateIssuedTimestamp: date.timeIntervalSince1970,
                expirationDateTimestamp: date.addingTimeInterval(2 * 365 * 86_400).timeIntervalSince1970,
                prescriptionType: VisionPrescription.PrescriptionType(id: 1, detail: "Glasses"),
                rightEye: VisionPrescription.LensSpecification(sphere: -1.25, cylinder: -0.5, axis: 180, vertexDistance: 12),
                leftEye: VisionPrescription.LensSpecification(sphere: -1.0),
                brand: nil,
                metadata: samples.metadata
            )
        )
    }
    private func cdaDocument(at date: Date) throws -> Sample {
        #if os(iOS)
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <ClinicalDocument xmlns="urn:hl7-org:v3">
          <realmCode code="US"/>
          <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
          <templateId root="2.16.840.1.113883.10.20.22.1.1"/>
          <id root="2.16.840.1.113883.19.5.99999.1"/>
          <code code="34133-9" codeSystem="2.16.840.1.113883.6.1"/>
          <title>Demo summary of care</title>
          <effectiveTime value="20261008"/>
          <confidentialityCode code="N" codeSystem="2.16.840.1.113883.5.25"/>
          <recordTarget><patientRole><id root="1"/><patient>
            <name><given>Jane</given><family>Appleseed</family></name>
          </patient></patientRole></recordTarget>
          <author><time value="20261008"/><assignedAuthor><id root="2"/><assignedPerson>
            <name><given>John</given><family>Doe</family></name>
          </assignedPerson></assignedAuthor></author>
          <custodian><assignedCustodian><representedCustodianOrganization><id root="3"/>
            <name>Demo Clinic</name>
          </representedCustodianOrganization></assignedCustodian></custodian>
          <component><structuredBody><component><section>
            <title>Notes</title><text>Written by the HealthKitReporter Example app</text>
          </section></component></structuredBody></component>
        </ClinicalDocument>
        """
        return CDADocument(
            identifier: DocumentType.cda.identifier ?? "",
            startTimestamp: date.timeIntervalSince1970,
            endTimestamp: date.timeIntervalSince1970,
            device: nil,
            sourceRevision: samples.sourceRevision,
            harmonized: CDADocument.Harmonized(
                title: nil,
                patientName: nil,
                authorName: nil,
                custodianName: nil,
                documentData: Data(xml.utf8).base64EncodedString(),
                metadata: samples.metadata
            )
        )
        #else
        throw HealthKitError.notAvailable("CDA documents are iOS only")
        #endif
    }
    @available(iOS 18.0, *)
    private func stateOfMind(at date: Date) -> StateOfMind {
        return StateOfMind(
            identifier: StateOfMindType.stateOfMind.identifier ?? "",
            startTimestamp: date.timeIntervalSince1970,
            endTimestamp: date.timeIntervalSince1970,
            device: nil,
            sourceRevision: samples.sourceRevision,
            harmonized: StateOfMind.Harmonized(
                kind: HKStateOfMind.Kind.momentaryEmotion.rawValue,
                valence: 0.6,
                valenceClassification: nil,
                labels: [HKStateOfMind.Label.happy.rawValue, HKStateOfMind.Label.grateful.rawValue],
                associations: [HKStateOfMind.Association.fitness.rawValue],
                metadata: samples.metadata
            )
        )
    }
    @available(iOS 18.0, *)
    private func assessments(at date: Date) -> [Sample] {
        let assessment = { (type: ScoredAssessmentType, answers: [Int]) in
            ScoredAssessment(
                identifier: type.identifier ?? "",
                startTimestamp: date.timeIntervalSince1970,
                endTimestamp: date.timeIntervalSince1970,
                device: nil,
                sourceRevision: self.samples.sourceRevision,
                harmonized: ScoredAssessment.Harmonized(answers: answers, score: nil, risk: nil, metadata: self.samples.metadata)
            )
        }
        return [assessment(.gad7, [1, 0, 1, 2, 0, 1, 0]), assessment(.phq9, [0, 1, 1, 0, 2, 0, 1, 0, 0])]
    }
    @available(iOS 18.0, *)
    private func effort(relate: Bool, completion: @escaping DemoCompletion) throws {
        try latestWorkout { [unowned self] result in
            guard case .success(let workout) = result else {
                completion(.failure(HealthKitError.invalidValue("Save a workout first")))
                return
            }
            let date = Date(timeIntervalSince1970: workout.endTimestamp)
            let effort = samples.quantity(.workoutEffortScore, value: 7, unit: "appleEffortScore", start: date)
            let writer = reporter.writer
            if relate {
                writer.relateWorkoutEffort(effort, toWorkout: workout.uuid) { status($0, $1, "Effort 7 related", completion) }
            } else {
                writer.unrelateWorkoutEffort(effort, fromWorkout: workout.uuid) { status($0, $1, "Effort unrelated", completion) }
            }
        }
    }
    /// Saves steps, then deletes the same payload
    private func deleteAfterSaving(completion: @escaping DemoCompletion) {
        let steps = samples.quantity(.stepCount, value: 10, unit: "count", start: Date().addingTimeInterval(-60), end: Date())
        reporter.writer.save(sample: steps) { [unowned self] success, error in
            guard success else {
                completion(.failure(error ?? HealthKitError.unknown()))
                return
            }
            reporter.writer.delete(sample: steps) { status($0, $1, "Saved, then deleted", completion) }
        }
    }
    /// Only steps this app wrote, carrying the demo marker
    private func deleteOwnSteps(completion: @escaping DemoCompletion) {
        let predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                HKQuery.predicateForObjects(from: HKSource.default()),
                HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyExternalUUID)
            ]
        )
        reporter.writer.deleteObjects(of: QuantityType.stepCount, predicate: predicate) { success, count, error in
            completion(success ? .success("Deleted \(count) of the demo's own step samples") : .failure(error ?? HealthKitError.unknown()))
        }
    }
}
