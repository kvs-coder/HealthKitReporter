//
//  Quantity.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Quantitiy: Identifiable, Sample, Original {
    public struct Harmonized: Codable {
        public let value: Double
        public let unit: String
        public let metadata: [String: String]?

        public init(
            value: Double,
            unit: String,
            metadata: [String: String]?
        ) {
            self.value = value
            self.unit = unit
            self.metadata = metadata
        }
    }

    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: Harmonized

    public init(quantitySample: HKQuantitySample) throws {
        self.identifier = quantitySample.quantityType.identifier
        self.startTimestamp = quantitySample.startDate.timeIntervalSince1970
        self.endTimestamp = quantitySample.endDate.timeIntervalSince1970
        self.device = Device(device: quantitySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: quantitySample.sourceRevision)
        self.harmonized = try quantitySample.harmonize()
    }

    public init(
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        device: Device?,
        sourceRevision: SourceRevision,
        harmonized: Harmonized
    ) {
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.harmonized = harmonized
    }

    func asOriginal() throws -> HKQuantitySample {
        guard
            let type = HKObjectType.quantityType(
                forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)
            )
        else {
            throw HealthKitError.invalidType(
                "Quantitiy type identifier: \(identifier) could not be foramtted"
            )
        }
        return HKQuantitySample(
            type: type,
            quantity: HKQuantity(
                unit: HKUnit.init(from: harmonized.unit),
                doubleValue: harmonized.value
            ),
            start: startTimestamp.asDate,
            end: endTimestamp.asDate,
            device: device?.asOriginal(),
            metadata: harmonized.metadata
        )
    }
}
