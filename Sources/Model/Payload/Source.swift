//
//  Source.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

/// **Source** the app or device that saved a sample
public struct Source: Codable {
    public let name: String
    public let bundleIdentifier: String

    init(source: HKSource) {
        self.name = source.name
        self.bundleIdentifier = source.bundleIdentifier
    }

    /// Creates the **Source** from its fields
    public init(name: String, bundleIdentifier: String) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
    }

    /// A copy with the given fields replaced; nil keeps the current value
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
    /**
     Makes a **Source** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
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
