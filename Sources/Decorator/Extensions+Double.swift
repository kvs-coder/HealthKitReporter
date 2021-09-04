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
