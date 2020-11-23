//
//  Correlation.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Correlation: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let quantitySamples: [Quantity]
        public let categorySamples: [Category]
        public let metadata: [String: String]?

        public init(
            quantitySamples: [Quantity],
            categorySamples: [Category],
            metadata: [String: String]?
        ) {
            self.quantitySamples = quantitySamples
            self.categorySamples = categorySamples
            self.metadata = metadata
        }
    }

    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: Harmonized

    init(correlation: HKCorrelation) throws {
        self.sourceRevision = SourceRevision(
            sourceRevision: correlation.sourceRevision
        )
        self.identifier = correlation.correlationType.identifier
        self.startTimestamp = correlation.startDate.timeIntervalSince1970
        self.endTimestamp = correlation.endDate.timeIntervalSince1970
        self.device = Device(device: correlation.device)
        self.harmonized = try correlation.harmonize()
    }
}
// MARK: - Original
extension Correlation: Original {
    func asOriginal() throws -> HKCorrelation {
        guard let type = identifier.objectType?.original as? HKCorrelationType else {
            throw HealthKitError.invalidType(
                "Correlation type identifier: \(identifier) could not be foramtted"
            )
        }
        var set = Set<HKSample>()
        for element in harmonized.categorySamples {
            if let category = try? element.asOriginal() {
                set.insert(category)
            }
        }
        for element in harmonized.quantitySamples {
            if let category = try? element.asOriginal() {
                set.insert(category)
            }
        }
        return HKCorrelation(
            type: type,
            start: startTimestamp.asDate,
            end: endTimestamp.asDate,
            objects: set,
            device: device?.asOriginal(),
            metadata: harmonized.metadata
        )
    }
}
