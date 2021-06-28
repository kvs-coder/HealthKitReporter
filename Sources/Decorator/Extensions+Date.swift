//
//  Extensions+Date.swift
//  HealthKitReporter
//
//  Created by Victor on 14.09.20.
//

import Foundation

public extension Date {
    static var iso8601: String {
        return "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    }

    var millisecondsSince1970: Double {
        return timeIntervalSince1970 * 1000
    }

    func formatted(
        with format: String,
        timezone: TimeZone? = TimeZone.current
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timezone
        let date = dateFormatter.string(from: self)
        return date
    }
    func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }
    func advanced(by n: TimeInterval) -> Date {
        return self + n
    }

    static func make(from millisecondsSince1970: Double) -> Date {
        return Date(timeIntervalSince1970: millisecondsSince1970.secondsSince1970)
    }
}
