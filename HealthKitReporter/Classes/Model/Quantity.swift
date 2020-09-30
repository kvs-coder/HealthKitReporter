//
//  Quantity.swift
//  HealthKitReporter
//
//  Created by KVS on 25.09.20.
//

import Foundation
import HealthKit

public struct Quantitiy: Identifiable, Sample, Writable {
    public let identifier: String
    public let startDate: String
    public let endDate: String
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: HKQuantitySample.Harmonized

    public init(quantitySample: HKQuantitySample) throws {
        self.identifier = quantitySample.quantityType.identifier
        self.startDate = quantitySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = quantitySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: quantitySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: quantitySample.sourceRevision)
        self.harmonized = try quantitySample.harmonize()
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
        guard
            let start = startDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ),
            let end = endDate.asDate(format: Date.yyyyMMddTHHmmssZZZZZ)
        else {
            throw HealthKitError.invalidValue(
                "Quantitiy start: \(startDate) and end: \(endDate) could not be formatted"
            )
        }
        return HKQuantitySample(
            type: type,
            quantity: HKQuantity(
                unit: HKUnit.init(from: harmonized.unit),
                doubleValue: harmonized.value
            ),
            start: start,
            end: end,
            device: device?.asOriginal(),
            metadata: harmonized.metadata
        )
    }
}
