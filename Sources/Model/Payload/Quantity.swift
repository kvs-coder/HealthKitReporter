//
//  Quantity.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

public struct Quantity: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let value: Double
        public let unit: String
        public let metadata: Metadata?

        public init(
            value: Double,
            unit: String,
            metadata: Metadata?
        ) {
            self.value = value
            self.unit = unit
            self.metadata = metadata
        }

        public func copyWith(
            value: Double? = nil,
            unit: String? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                value: value ?? self.value,
                unit: unit ?? self.unit,
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

    init(quantitySample: HKQuantitySample, unit: HKUnit) throws {
        self.uuid = quantitySample.uuid.uuidString
        self.identifier = quantitySample.quantityType.identifier
        self.startTimestamp = quantitySample.startDate.timeIntervalSince1970
        self.endTimestamp = quantitySample.endDate.timeIntervalSince1970
        self.device = Device(device: quantitySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: quantitySample.sourceRevision)
        self.harmonized = Harmonized(
            value: quantitySample.quantity.doubleValue(for: unit),
            unit: unit.unitString,
            metadata: quantitySample.metadata?.asMetadata
        )
    }
    init(quantitySample: HKQuantitySample) throws {
        self.uuid = quantitySample.uuid.uuidString
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
        self.uuid = UUID().uuidString
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.harmonized = harmonized
    }

    public func copyWith(
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        harmonized: Harmonized? = nil
    ) -> Quantity {
        return Quantity(
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
extension Quantity: Original {
    func asOriginal() throws -> HKQuantitySample {
        guard let type = identifier.objectType?.original as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "Quantitiy type identifier: \(identifier) could not be formatted"
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
            metadata: harmonized.metadata?.original
        )
    }
}
// MARK: - Payload
extension Quantity: Payload {
    public static func make(from dictionary: [String: Any]) throws -> Quantity {
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
        return Quantity(
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
    public static func collect(from array: [Any]) throws -> [Quantity] {
        var results = [Quantity]()
        for element in array {
            if let dictionary = element as? [String: Any] {
                let harmonized = try Quantity.make(from: dictionary)
                results.append(harmonized)
            }
        }
        return results
    }
}
// MARK: - Factory
extension Quantity {
    public static func collect(results: [HKSample], unit: HKUnit) -> [Quantity] {
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
}
// MARK: - Payload
extension Quantity.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> Quantity.Harmonized {
        guard
            let value = dictionary["value"] as? NSNumber,
            let unit = dictionary["unit"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return Quantity.Harmonized(
            value: Double(truncating: value),
            unit: unit,
            metadata: metadata?.asMetadata
        )
    }
}
// MARK: - UnitConvertable
extension Quantity: UnitConvertable {
    public func converted(to unit: String) throws -> Quantity {
        guard harmonized.unit != unit else {
            return self
        }
        return try Quantity(
            quantitySample: try asOriginal(),
            unit: HKUnit.init(from: unit)
        )
    }
}
