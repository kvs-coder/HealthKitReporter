//
//  Extensions+DateComponents.swift
//  HealthKitReporter
//
//  Created by Victor on 15.11.20.
//

import Foundation

// MARK: - Payload
extension DateComponents: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) -> DateComponents {
        return DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone.current,
            era: dictionary["era"] as? Int,
            year: dictionary["year"] as? Int,
            month: dictionary["month"] as? Int,
            day: dictionary["day"] as? Int,
            hour: dictionary["hour"] as? Int,
            minute: dictionary["minute"] as? Int,
            second: dictionary["second"] as? Int,
            nanosecond: dictionary["nanosecond"] as? Int,
            weekday: dictionary["weekday"] as? Int,
            weekdayOrdinal: dictionary["weekdayOrdinal"] as? Int,
            quarter: dictionary["quarter"] as? Int,
            weekOfMonth: dictionary["weekOfMonth"] as? Int,
            weekOfYear: dictionary["weekOfYear"] as? Int,
            yearForWeekOfYear: dictionary["yearForWeekOfYear"] as? Int
        )
    }
}


