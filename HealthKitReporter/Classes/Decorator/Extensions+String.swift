//
//  Extensions+String.swift
//  HealthKitReporter
//
//  Created by KVS on 25.09.20.
//

import Foundation

extension String {
    func asDate(format: String, timezone: TimeZone = TimeZone.current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timezone
        let date = dateFormatter.date(from: self)
        return date
    }
}
