//
//  Statistics.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Statistics: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let summary: Double?
        public let average: Double?
        public let recent: Double?
        public let min: Double?
        public let max: Double?
        public let unit: String

        public init(
            summary: Double?,
            average: Double?,
            recent: Double?,
            min: Double?,
            max: Double?,
            unit: String
        ) {
            self.summary = summary
            self.average = average
            self.recent = recent
            self.min = min
            self.max = max
            self.unit = unit
        }
    }

    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let harmonized: Harmonized
    public let sources: [Source]?

    init(statistics: HKStatistics, unit: HKUnit) throws {
        self.identifier = statistics.quantityType.identifier
        self.startTimestamp = statistics.startDate.timeIntervalSince1970
        self.endTimestamp = statistics.endDate.timeIntervalSince1970
        self.sources = statistics.sources?.map { Source(source: $0) }
        self.harmonized = Harmonized(
            summary: statistics.sumQuantity()?.doubleValue(for: unit),
            average: statistics.averageQuantity()?.doubleValue(for: unit),
            recent: statistics.mostRecentQuantity()?.doubleValue(for: unit),
            min: statistics.minimumQuantity()?.doubleValue(for: unit),
            max: statistics.maximumQuantity()?.doubleValue(for: unit),
            unit: unit.unitString
        )
    }

    init(statistics: HKStatistics) throws {
        self.identifier = statistics.quantityType.identifier
        self.startTimestamp = statistics.startDate.timeIntervalSince1970
        self.endTimestamp = statistics.endDate.timeIntervalSince1970
        self.sources = statistics.sources?.map { Source(source: $0) }
        self.harmonized = try statistics.harmonize()
    }
}
