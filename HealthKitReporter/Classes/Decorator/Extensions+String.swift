//
//  Extensions+String.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation

public extension String {
    var integer: Int? {
        return Int(self)
    }
    var double: Double? {
        return Double(self)
    }
    var boolean: Bool {
        return (self as NSString).boolValue
    }
    var objectType: ObjectType? {
        if let type = try? QuantityType.make(from: self) {
            return type
        }
        if let type = try? CategoryType.make(from: self) {
            return type
        }
        if let type = try? CharacteristicType.make(from: self) {
            return type
        }
        if let type = try? SeriesType.make(from: self) {
            return type
        }
        if let type = try? CorrelationType.make(from: self) {
            return type
        }
        if let type = try? DocumentType.make(from: self) {
            return type
        }
        if let type = try? ActivitySummaryType.make(from: self) {
            return type
        }
        if let type = try? WorkoutType.make(from: self) {
            return type
        }
        if #available(iOS 14.0, *) {
            if let type = try? ElectrocardiogramType.make(from: self) {
                return type
            }
        }
        return nil
    }

    func asDate(
        format: String,
        timezone: TimeZone = TimeZone.current
    ) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timezone
        let date = dateFormatter.date(from: self)
        return date
    }
}
