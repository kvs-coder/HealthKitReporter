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

    public init(from decoder: Decoder) throws {
        self.data = try decoder.singleValueContainer().decode(Data.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }

    var original: HKQueryAnchor? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
    }
}
