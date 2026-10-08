//
//  AuthorizationDemos.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import HealthKitReporter

/// Authorization for every type the library supports
final class AuthorizationDemos: DemoPerformer {
    private let reporter: HealthKitReporter

    init(reporter: HealthKitReporter) {
        self.reporter = reporter
    }

    func publisher(for row: DemoRow) -> AnyPublisher<String, Error> {
        reporter.publisher { [reporter] completion in
            let manager = reporter.manager
            let readTypes = reporter.demoReadTypes
            let writeTypes = reporter.demoWriteTypes
            switch row {
            case .requestAuthorization:
                manager.requestAuthorization(toRead: readTypes, toWrite: writeTypes) { success, error in
                    completion(
                        success
                            ? .success("Requested \(readTypes.count) read and \(writeTypes.count) write types")
                            : .failure(error ?? HealthKitError.unknown())
                    )
                }
            case .authorizationRequestStatus:
                manager.authorizationRequestStatus(toRead: readTypes, toWrite: writeTypes) { status, error in
                    completion(error.map { .failure($0) } ?? .success("Status: \(status)"))
                }
            case .isAuthorizedToWrite:
                let authorized = try writeTypes.filter { try reporter.writer.isAuthorizedToWrite(type: $0) }
                completion(.success("\(authorized.count) of \(writeTypes.count) writable types are authorized"))
            case .visionPrescriptionAuthorization:
                guard #available(iOS 16.0, *) else {
                    throw HealthKitError.notAvailable("Vision prescriptions need iOS 16")
                }
                manager.requestPerObjectReadAuthorization(for: VisionPrescriptionType.visionPrescription) {
                    completion($0 ? .success("Prescriptions chosen") : .failure($1 ?? HealthKitError.unknown()))
                }
            case .medicationAuthorization:
                guard #available(iOS 26.0, *) else {
                    throw HealthKitError.notAvailable("Medications need iOS 26")
                }
                manager.requestPerObjectReadAuthorization(for: MedicationType.userAnnotatedMedication) {
                    completion($0 ? .success("Medications chosen") : .failure($1 ?? HealthKitError.unknown()))
                }
            default:
                throw HealthKitError.invalidOption("\(row) is not an authorization demo")
            }
        }
    }
}
