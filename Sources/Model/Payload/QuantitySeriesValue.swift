//
//  QuantitySeriesValue.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import Foundation

/// One quantity inside a quantity series sample
public struct QuantitySeriesValue: Codable {
    public let value: Double
    public let unit: String
    /// seconds since 1970
    public let startTimestamp: Double
    /// seconds since 1970
    public let endTimestamp: Double
    /// uuid of the series sample the value belongs to; nil when writing
    public let sampleUUID: String?

    public init(
        value: Double,
        unit: String,
        startTimestamp: Double,
        endTimestamp: Double,
        sampleUUID: String? = nil
    ) {
        self.value = value
        self.unit = unit
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.sampleUUID = sampleUUID
    }
}
// MARK: - Payload
extension QuantitySeriesValue: Payload {
    public static func make(from dictionary: [String: Any]) throws -> QuantitySeriesValue {
        guard
            let value = dictionary["value"] as? NSNumber,
            let unit = dictionary["unit"] as? String,
            let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
            let endTimestamp = dictionary["endTimestamp"] as? NSNumber
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return QuantitySeriesValue(
            value: Double(truncating: value),
            unit: unit,
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: Double(truncating: endTimestamp),
            sampleUUID: dictionary["sampleUUID"] as? String
        )
    }
}
