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
    public let startDate: String
    public let endDate: String
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: HKCategorySample.Harmonized

    public init(categorySample: HKCategorySample) throws {
        self.identifier = categorySample.categoryType.identifier
        self.startDate = categorySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = categorySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
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
        guard
            let start = startDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ),
            let end = endDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ)
        else {
            throw HealthKitError.invalidValue(
                "Category start: \(startDate) and end: \(endDate) could not be formatted"
            )
        }
        return HKCategorySample(
            type: type,
            value: harmonized.value,
            start: start,
            end: end,
            device: device?.asOriginal(),
            metadata: harmonized.metadata
        )
    }
}
