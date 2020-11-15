//
//  Quantity.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Quantity: Identifiable, Sample {
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

    public static func collect(
        results: [HKSample],
        unit: HKUnit
    ) -> [Quantity] {
        var samples = [Quantity]()
        if let quantitySamples = results as? [HKQuantitySample] {
            for quantitySample in quantitySamples {
                do {
                    let sample = try Quantity(
                        quantitySample: quantitySample,
                        unit: unit
                    )
                    samples.append(sample)
                } catch {
                    continue
                }
            }
        }
        return samples
    }

    init(quantitySample: HKQuantitySample, unit: HKUnit) throws {
        self.identifier = quantitySample.quantityType.identifier
        self.startTimestamp = quantitySample.startDate.timeIntervalSince1970
        self.endTimestamp = quantitySample.endDate.timeIntervalSince1970
        self.device = Device(device: quantitySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: quantitySample.sourceRevision)
        self.harmonized = Harmonized(
            value: quantitySample.quantity.doubleValue(for: unit),
            unit: unit.unitString,
            metadata: quantitySample.metadata?.compactMapValues { String(describing: $0 )}
        )
    }

    init(quantitySample: HKQuantitySample) throws {
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
}
// MARK: - Original
extension Quantity: Original {
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
// MARK: - Payload
extension Quantity: Payload {
    public static func make(
        from dictionary: [String : Any]
    ) throws -> Quantity {
        guard
            let identifier = dictionary["identifier"] as? String,
            let startDate = (dictionary["startDate"] as? String)?
                .asDate(format: Date.iso8601),
            let endDate = (dictionary["endDate"] as? String)?
                .asDate(format: Date.iso8601),
            let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let device = dictionary["device"] as? [String: Any]
        return Quantity(
            identifier: identifier,
            startTimestamp: startDate.timeIntervalSince1970,
            endTimestamp: endDate.timeIntervalSince1970,
            device: device != nil
                ? try Device.make(from: device!)
                : nil,
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
// MARK: - Payload
extension Quantity.Harmonized: Payload {
    public static func make(
        from dictionary: [String : Any]
    ) throws -> Quantity.Harmonized {
        guard
            let value = dictionary["value"] as? Double,
            let unit = dictionary["unit"] as? String,
            let metadata = dictionary["metadata"] as? [String: String]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return Quantity.Harmonized(
            value: value,
            unit: unit,
            metadata: metadata
        )
    }
}
