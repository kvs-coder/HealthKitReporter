//
//  SamplePredicateOptions.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// Whether samples must start and end inside a date range, see **NSPredicate.samplesPredicate**
public struct SamplePredicateOptions: OptionSet, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The sample starts at or after the start date
    public static let strictStartDate = SamplePredicateOptions(rawValue: 1 << 0)
    /// The sample ends at or before the end date
    public static let strictEndDate = SamplePredicateOptions(rawValue: 1 << 1)

    var original: HKQueryOptions {
        var options = HKQueryOptions()
        if contains(.strictStartDate) {
            options.insert(.strictStartDate)
        }
        if contains(.strictEndDate) {
            options.insert(.strictEndDate)
        }
        return options
    }
}
