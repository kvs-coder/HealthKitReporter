//
//  VisionPrescription.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 04.10.22.
//

import HealthKit

@available(iOS 16.0, *)
public struct VisionPrescription: Identifiable, Sample {
    public struct PrescriptionType: Codable {
        public let id: Int
        public let detail: String

        init(id: Int, detail: String) {
            self.id = id
            self.detail = detail
        }

        init(prescriptionType: HKVisionPrescriptionType) {
            self.id = Int(prescriptionType.rawValue)
            self.detail = prescriptionType.detail
        }
    }

    public struct Harmonized: Codable {
        public let dateIssuedTimestamp: Double
        public let expirationDateTimestamp: Double?
        public let prescriptionType: PrescriptionType
        public let metadata: Metadata?

        init(
            dateIssuedTimestamp: Double,
            expirationDateTimestamp: Double?,
            prescriptionType: PrescriptionType,
            metadata: Metadata?
        ) {
            self.dateIssuedTimestamp = dateIssuedTimestamp
            self.expirationDateTimestamp = expirationDateTimestamp
            self.prescriptionType = prescriptionType
            self.metadata = metadata
        }
    }

    public let uuid: String
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: Harmonized

    init(
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        device: Device?,
        sourceRevision: SourceRevision,
        harmonized: Harmonized
    ) {
        self.uuid = UUID().uuidString
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.harmonized = harmonized
    }

    init(visionPrescription: HKVisionPrescription) throws {
        self.uuid = visionPrescription.uuid.uuidString
        self.identifier = VisionPrescriptionType
            .visionPrescription
            .original?
            .identifier ?? "HKVisionPrescriptionTypeIdentifier"
        self.startTimestamp = visionPrescription.startDate.timeIntervalSince1970
        self.endTimestamp = visionPrescription.endDate.timeIntervalSince1970
        self.device = Device(device: visionPrescription.device)
        self.sourceRevision = SourceRevision(sourceRevision: visionPrescription.sourceRevision)
        self.harmonized = try visionPrescription.harmonize()
    }
}
// MARK: - Payload
@available(iOS 16.0, *)
extension VisionPrescription.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> VisionPrescription.Harmonized {
        guard
            let dateIssuedTimestamp = dictionary["dateIssuedTimestamp"] as? NSNumber,
            let prescriptionType = dictionary["prescriptionType"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let expirationDateTimestamp = dictionary["expirationDateTimestamp"] as? NSNumber
        let metadata = dictionary["metadata"] as? [String: Any]
        return VisionPrescription.Harmonized(
            dateIssuedTimestamp: Double(truncating: dateIssuedTimestamp),
            expirationDateTimestamp: expirationDateTimestamp != nil
                ? Double(truncating: expirationDateTimestamp!)
                : nil,
            prescriptionType: try VisionPrescription.PrescriptionType.make(from: prescriptionType),
            metadata: metadata?.asMetadata
        )
    }
}
// MARK: - Payload
@available(iOS 16.0, *)
extension VisionPrescription.PrescriptionType: Payload {
    public static func make(from dictionary: [String: Any]) throws -> VisionPrescription.PrescriptionType {
        guard
            let id = dictionary["id"] as? NSNumber,
            let detail = dictionary["detail"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return VisionPrescription.PrescriptionType(id: id.intValue, detail: detail)
    }
}
// MARK: - Payload
@available(iOS 16.0, *)
extension VisionPrescription: Payload {
    public static func make(from dictionary: [String: Any]) throws -> VisionPrescription {
        guard
            let identifier = dictionary["identifier"] as? String,
            let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
            let endTimestamp = dictionary["endTimestamp"] as? NSNumber,
            let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let device = dictionary["device"] as? [String: Any]
        return VisionPrescription(
            identifier: identifier,
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: Double(truncating: endTimestamp),
            device: device != nil
                ? try Device.make(from: device!)
                : nil,
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
