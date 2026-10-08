//
//  Extensions+NSPredicate.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Foundation
import HealthKitReporter

extension NSPredicate {
    /// Last 7 days, the window every read demo uses
    static var lastWeek: NSPredicate {
        let now = Date()
        return Query.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .day, value: -7, to: now),
            end: now,
            options: .strictEndDate
        )
    }
}
