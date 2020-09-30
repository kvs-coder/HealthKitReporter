//
//  Extensions+NSPredicate.swift
//  HealthKitReporter
//
//  Created by Victor on 14.09.20.
//

import Foundation
import HealthKit

extension NSPredicate {
    public static var allSamples: NSPredicate {
        return HKQuery.predicateForSamples(
            withStart: .distantPast,
            end: .distantFuture,
            options: []
        )
    }
    public static func samplesPredicate(
        startDate: Date,
        endDate: Date,
        options: HKQueryOptions = []
    ) -> NSPredicate {
        return HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: options
        )
    }
}
