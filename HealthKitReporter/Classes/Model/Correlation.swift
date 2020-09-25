//
//  Correlation.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

public struct Correlation: Identifiable {
    public let identifier: String
    public let harmonized: HKCorrelation.Harmonized

    public init(correlation: HKCorrelation) throws {
        self.identifier = correlation.correlationType.identifier
        self.harmonized = try correlation.harmonize()
    }
}
