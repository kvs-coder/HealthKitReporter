//
//  Statistics.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Statistics: Identifiable, Sample {
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let harmonized: HKStatistics.Harmonized
    public let sources: [Source]?

    public init(statistics: HKStatistics) throws {
        self.identifier = statistics.quantityType.identifier
        self.startTimestamp = statistics.startDate.timeIntervalSince1970
        self.endTimestamp = statistics.endDate.timeIntervalSince1970
        self.sources = statistics.sources?.map { Source(source: $0 )}
        self.harmonized = try statistics.harmonize()
    }
}
