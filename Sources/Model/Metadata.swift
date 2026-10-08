//
//  Metadata.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 29.10.22.
//

import HealthKit

/**
 Sample metadata: a dictionary whose values may mix strings, numbers, booleans, dates and quantities.
 Encodes as a flat JSON object: strings, numbers and booleans as JSON values,
 a date as `{"timestamp": <seconds since 1970>}` and a quantity as `{"value": <number>, "unit": <unit>}`.
 */
public struct Metadata: Codable, Equatable {
    /// **Metadata** value
    public enum Value: Equatable {
        case string(String)
        case number(Double)
        case bool(Bool)
        /// seconds since 1970
        case date(timestamp: Double)
        case quantity(value: Double, unit: String)
    }

    public let values: [String: Value]

    public init(_ values: [String: Value]) {
        self.values = values
    }

    public subscript(key: String) -> Value? {
        return values[key]
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try container.decode([String: Value].self)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }
}
// MARK: - ExpressibleByDictionaryLiteral
extension Metadata: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Value)...) {
        self.init(Dictionary(elements, uniquingKeysWith: { _, last in last }))
    }
}
// MARK: - Payload
extension Metadata: Payload {
    /**
     Makes **Metadata** from a dictionary shaped like the Flutter plugin sends it
     or like HealthKit stores it.
     - Parameter dictionary: values are **String**, **NSNumber** (number or boolean), **Date**,
     **HKQuantity**, `["timestamp": NSNumber]` or `["value": NSNumber, "unit": String]`
     - Throws: HealthKitError.invalidValue for any other value
     */
    public static func make(from dictionary: [String: Any]) throws -> Metadata {
        var values = [String: Value]()
        for (key, element) in dictionary {
            guard let value = Value(element) else {
                throw HealthKitError.invalidValue("Invalid metadata value for \(key): \(element)")
            }
            values[key] = value
        }
        return Metadata(values)
    }
}
// MARK: - Original
extension Metadata {
    /**
     The HealthKit representation: **String**, **NSNumber**, **Date** and **HKQuantity** values.
     - Throws: HealthKitError.invalidValue on a malformed quantity unit
     */
    func asOriginal() throws -> [String: Any] {
        var original = [String: Any]()
        for (key, value) in values {
            original[key] = try value.asOriginal()
        }
        return original
    }
}
// MARK: - Value: Codable
extension Metadata.Value: Codable {
    private enum CodingKeys: String, CodingKey {
        case timestamp
        case value
        case unit
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if let bool = try? container.decode(Bool.self) {
                self = .bool(bool)
                return
            }
            if let number = try? container.decode(Double.self) {
                self = .number(number)
                return
            }
            if let string = try? container.decode(String.self) {
                self = .string(string)
                return
            }
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let timestamp = try container.decodeIfPresent(Double.self, forKey: .timestamp) {
            self = .date(timestamp: timestamp)
            return
        }
        self = .quantity(
            value: try container.decode(Double.self, forKey: .value),
            unit: try container.decode(String.self, forKey: .unit)
        )
    }
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string)
        case .number(let number):
            var container = encoder.singleValueContainer()
            try container.encode(number)
        case .bool(let bool):
            var container = encoder.singleValueContainer()
            try container.encode(bool)
        case .date(let timestamp):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(timestamp, forKey: .timestamp)
        case .quantity(let value, let unit):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .value)
            try container.encode(unit, forKey: .unit)
        }
    }
}
// MARK: - Value: Literals
extension Metadata.Value: ExpressibleByStringLiteral,
                          ExpressibleByFloatLiteral,
                          ExpressibleByIntegerLiteral,
                          ExpressibleByBooleanLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}
// MARK: - Value: Original
extension Metadata.Value {
    /// Units tried in order to express a metadata **HKQuantity**, which doesn't expose its own unit
    private static let quantityUnits: [HKUnit] = [
        .count().unitDivided(by: .minute()),
        .meter().unitDivided(by: .second()),
        .meter(),
        .kilocalorie().unitDivided(by: .gramUnit(with: .kilo).unitMultiplied(by: .hour())),
        .degreeCelsius(),
        .percent(),
        .second(),
        .kilocalorie(),
        .gramUnit(with: .kilo),
        .liter(),
        .millimeterOfMercury(),
        .decibelAWeightedSoundPressureLevel(),
        .count()
    ]

    init?(_ element: Any) {
        switch element {
        case let string as String:
            self = .string(string)
        case let number as NSNumber:
            self = CFGetTypeID(number) == CFBooleanGetTypeID()
                ? .bool(number.boolValue)
                : .number(number.doubleValue)
        case let date as Date:
            self = .date(timestamp: date.timeIntervalSince1970)
        case let quantity as HKQuantity:
            guard let unit = Self.quantityUnits.first(where: { quantity.is(compatibleWith: $0) }) else {
                return nil
            }
            self = .quantity(value: quantity.doubleValue(for: unit), unit: unit.unitString)
        case let dictionary as [String: Any]:
            if let timestamp = dictionary["timestamp"] as? NSNumber, dictionary.count == 1 {
                self = .date(timestamp: timestamp.doubleValue)
            } else if
                let value = dictionary["value"] as? NSNumber,
                let unit = dictionary["unit"] as? String,
                dictionary.count == 2 {
                self = .quantity(value: value.doubleValue, unit: unit)
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    func asOriginal() throws -> Any {
        switch self {
        case .string(let string):
            return string
        case .number(let number):
            return NSNumber(value: number)
        case .bool(let bool):
            return NSNumber(value: bool)
        case .date(let timestamp):
            return timestamp.asDate
        case .quantity(let value, let unit):
            return HKQuantity(unit: try HKUnit.parsed(from: unit), doubleValue: value)
        }
    }
}
