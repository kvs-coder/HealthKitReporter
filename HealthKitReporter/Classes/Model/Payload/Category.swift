//
//  Category.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Category: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let value: Int
        public let description: String
        public let metadata: [String: String]?

        public init(
            value: Int,
            description: String,
            metadata: [String: String]?
        ) {
            self.value = value
            self.description = description
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

    public static func collect(
        results: [HKSample]
    ) -> [Category] {
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
        uuid: String,
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
}
// MARK: - Original
extension Category: Original {
    func asOriginal() throws -> HKCategorySample {
        guard let type = identifier.objectType?.original as? HKCategoryType else {
            throw HealthKitError.invalidType(
                "Category type identifier: \(identifier) could not be formatted"
            )
        }
        return HKCategorySample(
            type: type,
            value: harmonized.value,
            start: startTimestamp.asDate,
            end: endTimestamp.asDate,
            device: device?.asOriginal(),
            metadata: harmonized.metadata
        )
    }
}
// MARK: - Payload
extension Category: Payload {
    public static func make(
        from dictionary: [String : Any]
    ) throws -> Category {
        guard
            let uuid = dictionary["uuid"] as? String,
            let identifier = dictionary["identifier"] as? String,
            let startTimestamp = dictionary["startTimestamp"] as? Double,
            let endTimestamp = dictionary["endTimestamp"] as? Double,
            let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let device = dictionary["device"] as? [String: Any]
        return Category(
            uuid: uuid,
            identifier: identifier,
            startTimestamp: startTimestamp.secondsSince1970,
            endTimestamp: endTimestamp.secondsSince1970,
            device: device != nil
                ? try Device.make(from: device!)
                : nil,
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
// MARK: - Payload
extension Category.Harmonized: Payload {
    public static func make(
        from dictionary: [String : Any]
    ) throws -> Category.Harmonized {
        guard
            let value = dictionary["value"] as? Int,
            let description = dictionary["description"] as? String,
            let metadata = dictionary["metadata"] as? [String: String]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return Category.Harmonized(
            value: value,
            description: description,
            metadata: metadata
        )
    }
}
