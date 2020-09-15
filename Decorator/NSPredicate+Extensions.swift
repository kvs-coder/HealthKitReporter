//
//  NSPredicate+Extensions.swift
//  HealthKitReporter
//
//  Created by Florian on 14.09.20.
//

import Foundation
import HealthKit

extension NSPredicate {
    static func queryPredicate(
        startDate: Date,
        endDate: Date,
        options: HKQueryOptions
    ) -> NSPredicate {
        return HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: options
        )
    }
}
