//
//  Attachment.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// File attached to a sample, e.g. a scanned prescription
public struct Attachment: Codable {
    /// uuid of the attachment
    public let identifier: String
    public let name: String
    /// uniform type identifier, e.g. "public.jpeg"
    public let contentType: String
    /// bytes
    public let size: Int
    /// seconds since 1970
    public let creationTimestamp: Double
    public let metadata: Metadata?

    public init(
        identifier: String,
        name: String,
        contentType: String,
        size: Int,
        creationTimestamp: Double,
        metadata: Metadata?
    ) {
        self.identifier = identifier
        self.name = name
        self.contentType = contentType
        self.size = size
        self.creationTimestamp = creationTimestamp
        self.metadata = metadata
    }

    @available(iOS 16.0, watchOS 9.0, *)
    init(attachment: HKAttachment) {
        self.identifier = attachment.identifier.uuidString
        self.name = attachment.name
        self.contentType = attachment.contentType.identifier
        self.size = attachment.size
        self.creationTimestamp = attachment.creationDate.timeIntervalSince1970
        self.metadata = attachment.metadata?.asMetadata
    }
}
// MARK: - Payload
extension Attachment: Payload {
    public static func make(from dictionary: [String: Any]) throws -> Attachment {
        guard
            let identifier = dictionary["identifier"] as? String,
            let name = dictionary["name"] as? String,
            let contentType = dictionary["contentType"] as? String,
            let size = dictionary["size"] as? NSNumber,
            let creationTimestamp = dictionary["creationTimestamp"] as? NSNumber
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return Attachment(
            identifier: identifier,
            name: name,
            contentType: contentType,
            size: size.intValue,
            creationTimestamp: Double(truncating: creationTimestamp),
            metadata: try metadata.map(Metadata.make)
        )
    }
}
