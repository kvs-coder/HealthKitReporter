//
//  Statistics.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

public struct Statistics: Identifiable, Sample {
    public let identifier: String
    public let startDate: String
    public let endDate: String
    public let harmonized: HKStatistics.Harmonized
    public let sources: [Source]?

    public init(statistics: HKStatistics) throws {
        self.identifier = statistics.quantityType.identifier
        self.startDate = statistics.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = statistics.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.sources = statistics.sources?.map { Source(source: $0 )}
        self.harmonized = try statistics.harmonize()
    }
}
