//
//  Source.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

public struct Source: Codable {
    public let name: String
    public let bundleIdentifier: String

    public init(source: HKSource) {
        self.name = source.name
        self.bundleIdentifier = source.bundleIdentifier
    }
}
