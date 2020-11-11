//
//  Extensions+Date.swift
//  HealthKitReporter
//
//  Created by Victor on 14.09.20.
//

import Foundation
import HealthKit

public extension Date {
    static var yyyyMMdd: String {
        return "yyyy-MM-dd"
    }
    static var yyyyMMddTHHmmssZZZZZ: String {
         return "\(yyyyMMdd)'T'HH:mm:ssZZZZZ"
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
}
