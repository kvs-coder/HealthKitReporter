//
//  Extensions+Double.swift
//  HealthKitReporter
//
//  Created by Florian on 30.09.20.
//

import Foundation

extension Double {
    var asDate: Date {
        return Date(timeIntervalSince1970: self)
    }
}
