//
//  Source.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Source: Codable, Original {
    public let name: String
    public let bundleIdentifier: String

    init(source: HKSource) {
        self.name = source.name
        self.bundleIdentifier = source.bundleIdentifier
    }

    public init(name: String, bundleIdentifier: String) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
    }

    func asOriginal() throws -> HKSource {
        return HKSource.default()
    }
}
