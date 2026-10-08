//
//  CDADocument.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

#if os(iOS)
import HealthKit

/// Consolidated Clinical Document (CDA) sample
public struct CDADocument: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let title: String?
        public let patientName: String?
        public let authorName: String?
        public let custodianName: String?
        /// base64 encoded CDA XML; nil unless the document query includes document data
        public let documentData: String?
        public let metadata: Metadata?

        public init(
            title: String?,
            patientName: String?,
            authorName: String?,
            custodianName: String?,
            documentData: String?,
            metadata: Metadata?
        ) {
            self.title = title
            self.patientName = patientName
            self.authorName = authorName
            self.custodianName = custodianName
            self.documentData = documentData
            self.metadata = metadata
        }

        public func copyWith(
            title: String? = nil,
            patientName: String? = nil,
            authorName: String? = nil,
            custodianName: String? = nil,
            documentData: String? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                title: title ?? self.title,
                patientName: patientName ?? self.patientName,
                authorName: authorName ?? self.authorName,
                custodianName: custodianName ?? self.custodianName,
                documentData: documentData ?? self.documentData,
                metadata: metadata ?? self.metadata
            )
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

    init(documentSample: HKCDADocumentSample) {
        self.uuid = documentSample.uuid.uuidString
        self.identifier = documentSample.documentType.identifier
        self.startTimestamp = documentSample.startDate.timeIntervalSince1970
        self.endTimestamp = documentSample.endDate.timeIntervalSince1970
        self.device = Device(device: documentSample.device)
        self.sourceRevision = SourceRevision(sourceRevision: documentSample.sourceRevision)
        let document = documentSample.document
        self.harmonized = Harmonized(
            title: document?.title,
            patientName: document?.patientName,
            authorName: document?.authorName,
            custodianName: document?.custodianName,
            documentData: document?.documentData?.base64EncodedString(),
            metadata: documentSample.metadata?.asMetadata
        )
    }

    public func copyWith(
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        harmonized: Harmonized? = nil
    ) -> CDADocument {
        return CDADocument(
            identifier: identifier ?? self.identifier,
            startTimestamp: startTimestamp ?? self.startTimestamp,
            endTimestamp: endTimestamp ?? self.endTimestamp,
            device: device ?? self.device,
            sourceRevision: sourceRevision ?? self.sourceRevision,
            harmonized: harmonized ?? self.harmonized
        )
    }
}
// MARK: - Original
extension CDADocument: Original {
    /// Title, patient, author and custodian are extracted by HealthKit from the CDA XML
    func asOriginal() throws -> HKCDADocumentSample {
        guard
            let documentData = harmonized.documentData,
            let data = Data(base64Encoded: documentData)
        else {
            throw HealthKitError.invalidValue("CDA document data is not base64 encoded XML")
        }
        return try HKCDADocumentSample(
            data: data,
            start: startTimestamp.asDate,
            end: endTimestamp.asDate,
            metadata: try harmonized.metadata?.asOriginal()
        )
    }
}
// MARK: - Payload
extension CDADocument: Payload {
    public static func make(from dictionary: [String: Any]) throws -> CDADocument {
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
        return CDADocument(
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
extension CDADocument {
    public static func collect(results: [HKSample]) -> [CDADocument] {
        return results
            .compactMap { $0 as? HKCDADocumentSample }
            .map { CDADocument(documentSample: $0) }
    }
}
// MARK: - Harmonized: Payload
extension CDADocument.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> CDADocument.Harmonized {
        let metadata = dictionary["metadata"] as? [String: Any]
        return CDADocument.Harmonized(
            title: dictionary["title"] as? String,
            patientName: dictionary["patientName"] as? String,
            authorName: dictionary["authorName"] as? String,
            custodianName: dictionary["custodianName"] as? String,
            documentData: dictionary["documentData"] as? String,
            metadata: try metadata.map(Metadata.make)
        )
    }
}
#endif
