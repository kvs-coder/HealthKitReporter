//
//  ActivitySummary.swift
//  HealthKitReporter
//
//  Created by KVS on 25.09.20.
//

import Foundation
import HealthKit

public struct ActivitySummary: Identifiable {
    public let identifier: String
    public let date: String?
    public let harmonized: HKActivitySummary.Harmonized

    public init(activitySummary: HKActivitySummary) throws {
        self.identifier = HealthKitType
            .activitySummary
            .rawValue?
            .identifier ?? "HKActivitySummaryType"
        self.date = activitySummary
            .dateComponents(for: Calendar.current)
            .date?
            .formatted(with: Date.yyyyMMddTHHmmssZZZZZ)
        self.harmonized = try activitySummary.harmonize()
    }
}
