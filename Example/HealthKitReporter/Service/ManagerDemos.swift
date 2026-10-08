//
//  ManagerDemos.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import HealthKit
import HealthKitReporter
import UIKit

/// Units, dates, recalibration, the watch app, stopping live queries and attachments
final class ManagerDemos: DemoPerformer {
    private let reporter: HealthKitReporter
    private let liveQueries: LiveQueries

    init(reporter: HealthKitReporter, liveQueries: LiveQueries) {
        self.reporter = reporter
        self.liveQueries = liveQueries
    }

    func publisher(for row: DemoRow) -> AnyPublisher<String, Error> {
        reporter.publisher { [unowned self] completion in
            let manager = reporter.manager
            switch row {
            case .preferredUnits:
                manager.preferredUnits(for: reporter.demoQuantityTypes) { units, error in
                    completion(error.map { .failure($0) } ?? .success(units.summary("preferred units")))
                }
            case .earliestPermittedSampleDate:
                completion(.success("\(manager.earliestPermittedSampleDate())"))
            case .recalibrateEstimates:
                manager.recalibrateEstimates(for: QuantityType.sixMinuteWalkTestDistance, at: Date()) {
                    completion($0 ? .success("Recalibrated") : .failure($1 ?? HealthKitError.unknown()))
                }
            case .startWatchApp:
                manager.startWatchApp(with: runConfiguration) {
                    completion($0 ? .success("Watch app started, run on the watch") : .failure($1 ?? HealthKitError.unknown()))
                }
            case .stopQuery:
                completion(.success("Stopped \(liveQueries.stopAll()) live queries"))
            case .addAttachment, .attachments, .attachmentData, .removeAttachment:
                guard #available(iOS 16.0, *) else {
                    throw HealthKitError.notAvailable("Attachments need iOS 16")
                }
                try attachment(row, completion: completion)
            default:
                throw HealthKitError.invalidOption("\(row) is not a manager demo")
            }
        }
    }

    private var runConfiguration: WorkoutConfiguration {
        return WorkoutConfiguration(
            activityValue: Int(HKWorkoutActivityType.running.rawValue),
            locationValue: HKWorkoutSessionLocationType.outdoor.rawValue,
            swimmingValue: HKWorkoutSwimmingLocationType.unknown.rawValue,
            harmonized: WorkoutConfiguration.Harmonized(value: 400, unit: "m")
        )
    }

    /// Attachments belong to the newest glasses prescription the demo saved
    @available(iOS 16.0, *)
    private func attachment(_ row: DemoRow, completion: @escaping DemoCompletion) throws {
        let query = try reporter.reader.visionPrescriptionQuery(limit: 1) { [unowned self] prescriptions, error in
            guard let uuid = prescriptions.first?.uuid else {
                completion(.failure(error ?? HealthKitError.invalidValue("Save glasses and grant access first")))
                return
            }
            switch row {
            case .addAttachment:
                addScan(to: uuid, completion: completion)
            case .attachments:
                reporter.manager.attachments(forSampleOf: VisionPrescriptionType.visionPrescription, uuid: uuid) {
                    completion($1.map { .failure($0) } ?? .success($0.summary("attachments")))
                }
            default:
                firstAttachment(of: uuid, row: row, completion: completion)
            }
        }
        reporter.manager.executeQuery(query)
    }
    @available(iOS 16.0, *)
    private func addScan(to uuid: String, completion: @escaping DemoCompletion) {
        reporter.manager.addAttachment(
            toSampleOf: VisionPrescriptionType.visionPrescription,
            uuid: uuid,
            name: "scan.png",
            contentType: "public.png",
            url: scanImageURL
        ) { attachment, error in
            completion(attachment.map { .success($0.json) } ?? .failure(error ?? HealthKitError.unknown()))
        }
    }
    @available(iOS 16.0, *)
    private func firstAttachment(of uuid: String, row: DemoRow, completion: @escaping DemoCompletion) {
        let manager = reporter.manager
        let type = VisionPrescriptionType.visionPrescription
        manager.attachments(forSampleOf: type, uuid: uuid) { attachments, error in
            guard let attachment = attachments.first else {
                completion(.failure(error ?? HealthKitError.invalidValue("Attach a scan first")))
                return
            }
            guard row == .attachmentData else {
                manager.removeAttachment(fromSampleOf: type, uuid: uuid, attachmentIdentifier: attachment.identifier) {
                    completion($0 ? .success("Removed \(attachment.name)") : .failure($1 ?? HealthKitError.unknown()))
                }
                return
            }
            manager.attachmentData(forSampleOf: type, uuid: uuid, attachmentIdentifier: attachment.identifier) {
                completion($0.map { .success("\(attachment.name): \($0.count) bytes") } ?? .failure($1 ?? HealthKitError.unknown()))
            }
        }
    }

    /// A small image written to a temporary file, the "scan" attached to the prescription
    private var scanImageURL: URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("scan.png")
        let image = UIGraphicsImageRenderer(size: CGSize(width: 120, height: 80)).image { context in
            UIColor.systemTeal.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 120, height: 80))
        }
        try? image.pngData()?.write(to: url)
        return url
    }
}
