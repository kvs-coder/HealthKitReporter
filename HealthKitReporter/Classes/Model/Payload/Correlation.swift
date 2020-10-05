//
//  Correlation.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Correlation: Identifiable {
    public struct Harmonized: Codable {
        public let quantitySamples: [Quantity]
        public let categorySamples: [Category]
        public let metadata: [String: String]?

        public init(
            quantitySamples: [Quantity],
            categorySamples: [Category],
            metadata: [String: String]?
        ) {
            self.quantitySamples = quantitySamples
            self.categorySamples = categorySamples
            self.metadata = metadata
        }
    }

    public let identifier: String
    public let harmonized: Harmonized

    public init(correlation: HKCorrelation) throws {
        self.identifier = correlation.correlationType.identifier
        self.harmonized = try correlation.harmonize()
    }
}
