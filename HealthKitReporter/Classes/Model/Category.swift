//
//  Category.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Category: Identifiable, Sample, Writable {
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: HKCategorySample.Harmonized

    public init(categorySample: HKCategorySample) throws {
        self.identifier = categorySample.categoryType.identifier
        self.startTimestamp = categorySample.startDate.timeIntervalSince1970
        self.endTimestamp = categorySample.endDate.timeIntervalSince1970
        self.device = Device(device: categorySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: categorySample.sourceRevision)
        self.harmonized = try categorySample.harmonize()
    }

    func asOriginal() throws -> HKCategorySample {
        guard let type = HKObjectType.categoryType(
            forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)
        ) else {
            throw HealthKitError.invalidType(
                "Category type identifier: \(identifier) could not be foramtted"
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
