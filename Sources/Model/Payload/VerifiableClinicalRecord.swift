//
//  VerifiableClinicalRecord.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

#if os(iOS)
import HealthKit

/// Verifiable clinical record such as a SMART Health Card. Read only
public struct VerifiableClinicalRecord: Identifiable, Sample {
    public struct Subject: Codable {
        public let fullName: String
        /// yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ
        public let dateOfBirth: String?

        public init(fullName: String, dateOfBirth: String?) {
            self.fullName = fullName
            self.dateOfBirth = dateOfBirth
        }
    }

    public struct Harmonized: Codable {
        public let recordTypes: [String]
        public let issuerIdentifier: String
        public let subject: Subject
        /// seconds since 1970
        public let issuedTimestamp: Double
        /// seconds since 1970
        public let relevantTimestamp: Double
        /// seconds since 1970
        public let expirationTimestamp: Double?
        public let itemNames: [String]
        /// e.g. SMART Health Card, EU Digital COVID Certificate
        public let sourceType: String?
        /// base64 encoded record (JWS for SMART Health Cards); empty before iOS 15.4
        public let dataRepresentation: String

        public init(
            recordTypes: [String],
            issuerIdentifier: String,
            subject: Subject,
            issuedTimestamp: Double,
            relevantTimestamp: Double,
            expirationTimestamp: Double?,
            itemNames: [String],
            sourceType: String?,
            dataRepresentation: String
        ) {
            self.recordTypes = recordTypes
            self.issuerIdentifier = issuerIdentifier
            self.subject = subject
            self.issuedTimestamp = issuedTimestamp
            self.relevantTimestamp = relevantTimestamp
            self.expirationTimestamp = expirationTimestamp
            self.itemNames = itemNames
            self.sourceType = sourceType
            self.dataRepresentation = dataRepresentation
        }
    }

    public let uuid: String
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: Harmonized

    public init(
        uuid: String = UUID().uuidString,
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        device: Device?,
        sourceRevision: SourceRevision,
        harmonized: Harmonized
    ) {
        self.uuid = uuid
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.harmonized = harmonized
    }

    init(verifiableClinicalRecord record: HKVerifiableClinicalRecord) {
        var sourceType: String?
        var data = Data()
        if #available(iOS 15.4, *) {
            sourceType = record.sourceType?.rawValue
            data = record.dataRepresentation
        }
        self.uuid = record.uuid.uuidString
        self.identifier = record.sampleType.identifier
        self.startTimestamp = record.startDate.timeIntervalSince1970
        self.endTimestamp = record.endDate.timeIntervalSince1970
        self.device = Device(device: record.device)
        self.sourceRevision = SourceRevision(sourceRevision: record.sourceRevision)
        self.harmonized = Harmonized(
            recordTypes: record.recordTypes,
            issuerIdentifier: record.issuerIdentifier,
            subject: Subject(
                fullName: record.subject.fullName,
                dateOfBirth: record.subject.dateOfBirthComponents?.date?.formatted(with: Date.iso8601)
            ),
            issuedTimestamp: record.issuedDate.timeIntervalSince1970,
            relevantTimestamp: record.relevantDate.timeIntervalSince1970,
            expirationTimestamp: record.expirationDate?.timeIntervalSince1970,
            itemNames: record.itemNames,
            sourceType: sourceType,
            dataRepresentation: data.base64EncodedString()
        )
    }
}
// MARK: - Payload
extension VerifiableClinicalRecord: Payload {
    public static func make(from dictionary: [String: Any]) throws -> VerifiableClinicalRecord {
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
        return VerifiableClinicalRecord(
            uuid: dictionary.payloadUUID,
            identifier: identifier,
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: Double(truncating: endTimestamp),
            device: try device.map(Device.make),
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
// MARK: - Factory
extension VerifiableClinicalRecord {
    static func collect(results: [HKVerifiableClinicalRecord]) -> [VerifiableClinicalRecord] {
        return results.map { VerifiableClinicalRecord(verifiableClinicalRecord: $0) }
    }
}
// MARK: - Harmonized: Payload
extension VerifiableClinicalRecord.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> VerifiableClinicalRecord.Harmonized {
        guard
            let recordTypes = dictionary["recordTypes"] as? [String],
            let issuerIdentifier = dictionary["issuerIdentifier"] as? String,
            let subject = dictionary["subject"] as? [String: Any],
            let fullName = subject["fullName"] as? String,
            let issuedTimestamp = dictionary["issuedTimestamp"] as? NSNumber,
            let relevantTimestamp = dictionary["relevantTimestamp"] as? NSNumber,
            let itemNames = dictionary["itemNames"] as? [String],
            let dataRepresentation = dictionary["dataRepresentation"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let expirationTimestamp = dictionary["expirationTimestamp"] as? NSNumber
        return VerifiableClinicalRecord.Harmonized(
            recordTypes: recordTypes,
            issuerIdentifier: issuerIdentifier,
            subject: VerifiableClinicalRecord.Subject(
                fullName: fullName,
                dateOfBirth: subject["dateOfBirth"] as? String
            ),
            issuedTimestamp: Double(truncating: issuedTimestamp),
            relevantTimestamp: Double(truncating: relevantTimestamp),
            expirationTimestamp: expirationTimestamp.map { Double(truncating: $0) },
            itemNames: itemNames,
            sourceType: dictionary["sourceType"] as? String,
            dataRepresentation: dataRepresentation
        )
    }
}
#endif
