//
//  Source.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

@objc(HKRSource)
public final class Source: NSObject, Codable {
    @objc
    public let name: String
    @objc
    public let bundleIdentifier: String

    init(source: HKSource) {
        self.name = source.name
        self.bundleIdentifier = source.bundleIdentifier
    }

    @objc
    public init(name: String, bundleIdentifier: String) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
    }

    @objc
    public func copyWith(
        name: String? = nil,
        bundleIdentifier: String? = nil
    ) -> Source {
        return Source(
            name: name ?? self.name,
            bundleIdentifier: bundleIdentifier ?? self.bundleIdentifier
        )
    }
}
// MARK: - Original
extension Source: Original {
    func asOriginal() throws -> HKSource {
        return HKSource.default()
    }
}
// MARK: - Payload
extension Source: Payload {
    @objc
    public static func make(from dictionary: [String: Any]) throws -> Source {
        guard
            let name = dictionary["name"] as? String,
            let bundleIdentifier = dictionary["bundleIdentifier"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return Source(name: name, bundleIdentifier: bundleIdentifier)
    }
}
