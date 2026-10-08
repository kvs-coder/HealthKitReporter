//
//  Category.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

public struct Category: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let value: Int
        public let description: String
        public let detail: String
        public let metadata: Metadata?

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
    public static func collect(from array: [Any]) throws -> [Category] {
        var results = [Category]()
        for element in array {
            if let dictionary = element as? [String: Any] {
                let harmonized = try Category.make(from: dictionary)
                results.append(harmonized)
            }
        }
        return results
    }
}
// MARK: - Factory
extension Category {
    static func collect(results: [HKSample]) -> [Category] {
        var samples = [Category]()
        if let categorySamples = results as? [HKCategorySample] {
            for categorySample in categorySamples {
                do {
                    let sample = try Category(
                        categorySample: categorySample
                    )
                    samples.append(sample)
                } catch {
                    continue
                }
            }
        }
        return samples
    }
}
// MARK: - Payload
extension Category.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> Category.Harmonized {
        guard
            let value = dictionary["value"] as? Int,
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
