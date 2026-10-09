//
//  Category.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

/// **Category** a category sample, e.g. sleep analysis or a symptom
public struct Category: Identifiable, Sample {
    /// The value part of **Category**, with its metadata
    public struct Harmonized: Codable {
        public let value: Int
        public let description: String
        public let detail: String
        public let metadata: Metadata?

        /// Creates the **Harmonized** from its fields
        public init(
            value: Int,
            description: String,
            detail: String,
            metadata: Metadata?
        ) {
            self.value = value
            self.description = description
            self.detail = detail
            self.metadata = metadata
        }

        /// A copy with the given fields replaced; nil keeps the current value
        public func copyWith(
            value: Int? = nil,
            description: String? = nil,
            detail: String? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                value: value ?? self.value,
                description: description ?? self.description,
                detail: detail ?? self.detail,
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

    init(categorySample: HKCategorySample) throws {
        self.uuid = categorySample.uuid.uuidString
        self.identifier = categorySample.categoryType.identifier
        self.startTimestamp = categorySample.startDate.timeIntervalSince1970
        self.endTimestamp = categorySample.endDate.timeIntervalSince1970
        self.device = Device(device: categorySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: categorySample.sourceRevision)
        self.harmonized = try categorySample.harmonize()
    }

    /**
     Creates the payload. **uuid** names the stored sample; a new one by default,
     since HealthKit gives every saved sample its own
     */
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

    /// A copy with the given fields replaced; nil keeps the current value, including the **uuid**
    public func copyWith(
        uuid: String? = nil,
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        harmonized: Harmonized? = nil
    ) -> Category {
        return Category(
            uuid: uuid ?? self.uuid,
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
extension Category: Original {
    func asOriginal() throws -> HKCategorySample {
        try startTimestamp.checkInterval(to: endTimestamp)
        guard let type = identifier.objectType?.hkObjectType as? HKCategoryType else {
            throw HealthKitError.invalidType(
                "Category type identifier: \(identifier) could not be formatted"
            )
        }
        guard
            let value = try CategoryType.make(from: identifier).describedValue(harmonized.value),
            value.detail != "Unknown"
        else {
            throw HealthKitError.invalidValue("Value \(harmonized.value) is not valid for \(identifier)")
        }
        return HKCategorySample(
            type: type,
            value: harmonized.value,
            start: startTimestamp.asDate,
            end: endTimestamp.asDate,
            device: device?.asOriginal(),
            metadata: try harmonized.metadata?.asOriginal()
        )
    }
}
// MARK: - Payload
extension Category: Payload {
    /**
     Makes a **Category** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> Category {
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
        return Category(
            uuid: dictionary.payloadUUID,
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
// MARK: - Factory
extension Category {
    static func collect(results: [HKSample]) throws -> [Category] {
        return try results.converted { (sample: HKCategorySample) in
            try Category(categorySample: sample)
        }
    }
}
// MARK: - Payload
extension Category.Harmonized: Payload {
    /**
     Makes a **Category.Harmonized** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> Category.Harmonized {
        guard
            let value = dictionary.int("value"),
            let description = dictionary["description"] as? String,
            let detail = dictionary["detail"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return Category.Harmonized(
            value: value,
            description: description,
            detail: detail,
            metadata: try metadata.map(Metadata.make)
        )
    }
}
