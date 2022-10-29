//
//  Metadata.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 29.10.22.
//

import Foundation

public enum Metadata: Codable {
    case string(dictionary: [String: String]?)
    case date(dictionary: [String: Date]?)
    case double(dictionary: [String: Double]?)

    public var original: [String: Any]? {
        switch self {
        case .string(dictionary: let dictionary):
            return dictionary
        case .date(dictionary: let dictionary):
            return dictionary
        case .double(dictionary: let dictionary):
            return dictionary
        }
    }
}
// MARK: - Metadata: ExpressibleByDictionaryLiteral, Equatable
extension Metadata: ExpressibleByDictionaryLiteral, Equatable {
    public typealias Key = String
    public typealias Value = Any

    public init(dictionaryLiteral elements: (Key, Value)...) {
        var dictionary = [String: Any]()
        for pair in elements {
            dictionary[pair.0] = pair.1
        }
        do {
            self = try Metadata.make(from: dictionary)
        } catch {
            self = [:]
        }
    }
}
// MARK: - Metadata: Payload
extension Metadata: Payload {
    public static func make(from dictionary: [String : Any]) throws -> Metadata {
        if let stringDictionary = dictionary as? [String: String] {
            return Metadata.string(dictionary: stringDictionary)
        }
        if let dateDictionary = dictionary as? [String: Date] {
            return Metadata.date(dictionary: dateDictionary)
        }
        if let doubleDictionary = dictionary as? [String: Double] {
            return Metadata.double(dictionary: doubleDictionary)
        }
        throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
    }
}
