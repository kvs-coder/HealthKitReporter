//
//  Extensions+DateComponents.swift
//  HealthKitReporter
//
//  Created by Victor on 15.11.20.
//

import Foundation

// MARK: - Payload
extension DateComponents: Payload {
    /**
     Makes **DateComponents** in the current calendar and time zone from a dictionary of component names,
     e.g. ["day": 1]; missing components stay nil
     - Parameter dictionary: **[String: Any]** dictionary
     */
    public static func make(
        from dictionary: [String: Any]
    ) -> DateComponents {
        return DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone.current,
            era: dictionary.int("era"),
            year: dictionary.int("year"),
            month: dictionary.int("month"),
            day: dictionary.int("day"),
            hour: dictionary.int("hour"),
            minute: dictionary.int("minute"),
            second: dictionary.int("second"),
            nanosecond: dictionary.int("nanosecond"),
            weekday: dictionary.int("weekday"),
            weekdayOrdinal: dictionary.int("weekdayOrdinal"),
            quarter: dictionary.int("quarter"),
            weekOfMonth: dictionary.int("weekOfMonth"),
            weekOfYear: dictionary.int("weekOfYear"),
            yearForWeekOfYear: dictionary.int("yearForWeekOfYear")
        )
    }
}


