//
//  Extensions+NSPredicate.swift
//  HealthKitReporter
//
//  Created by Victor on 14.09.20.
//

import HealthKit

public extension NSPredicate {
    static var allSamples: NSPredicate {
        return HKQuery.predicateForSamples(
            withStart: .distantPast,
            end: .distantFuture,
            options: []
        )
    }
    /**
     Samples between two dates.
     - Parameter startDate: **Date** start
     - Parameter endDate: **Date** end
     - Parameter options: **SamplePredicateOptions** whether samples must start and end inside the range.
     Both by default
     - Returns: **NSPredicate** predicate
     */
    static func samplesPredicate(
        startDate: Date,
        endDate: Date,
        options: SamplePredicateOptions = [.strictStartDate, .strictEndDate]
    ) -> NSPredicate {
        return HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: options.original
        )
    }
    static func activitySummaryPredicate(
        dateComponents: DateComponents
    ) -> NSPredicate {
        return HKQuery.predicateForActivitySummary(with: dateComponents)
    }
    static func activitySummaryPredicateBetween(
        start: DateComponents,
        end: DateComponents
    ) -> NSPredicate {
        return HKQuery.predicate(forActivitySummariesBetweenStart: start, end: end)
    }
}
