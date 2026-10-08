//
//  Extensions+Double.swift
//  HealthKitReporter
//
//  Created by Victor on 30.09.20.
//

import Foundation

public extension Double {
    var asDate: Date {
        return Date(timeIntervalSince1970: self)
    }
    var secondsSince1970: Double {
        return (self / 1000)
    }
}
extension Double {
    /// Throws when `end` comes before this start timestamp; HealthKit raises for such intervals
    func checkInterval(to end: Double?) throws {
        guard let end = end, end < self else {
            return
        }
        throw HealthKitError.invalidValue("End \(end) is before start \(self)")
    }
}
