//
//  Anchor.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/**
 Position of an anchored query, so the next run only delivers changes.
 **data** is the archived HealthKit anchor; it encodes as a single base64 string, so it can be persisted as is
 */
public struct Anchor: Codable, Equatable {
    public let data: Data

    /// Creates the anchor from the archived data an earlier query handed back
    public init(data: Data) {
        self.data = data
    }

    init?(_ anchor: HKQueryAnchor?) {
        guard
            let anchor = anchor,
            let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
        else {
            return nil
        }
        self.data = data
    }

    /// Decodes the anchor from its base64 string
    public init(from decoder: Decoder) throws {
        self.data = try decoder.singleValueContainer().decode(Data.self)
    }

    /// Encodes the value as its JSON form
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }

    /// The archived HealthKit anchor; data that doesn't hold one throws HealthKitError.invalidValue
    func asOriginal() throws -> HKQueryAnchor {
        guard
            let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
        else {
            throw HealthKitError.invalidValue("Anchor data does not hold a HealthKit anchor")
        }
        return anchor
    }
}
