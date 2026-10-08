//
//  Extensions+String.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation

/// Every wrapped **ObjectType** available on the current OS, keyed by its HealthKit identifier
private let objectTypesByIdentifier: [String: ObjectType] = {
    let types: [[ObjectType]] = [
        QuantityType.allCases,
        CategoryType.allCases,
        CharacteristicType.allCases,
        SeriesType.allCases,
        CorrelationType.allCases,
        DocumentType.allCases,
        ActivitySummaryType.allCases,
        WorkoutType.allCases,
        ElectrocardiogramType.allCases,
        ClinicalType.allCases,
        VisionPrescriptionType.allCases,
        AudiogramType.allCases,
        StateOfMindType.allCases,
        ScoredAssessmentType.allCases,
        MedicationType.allCases
    ]
    return Dictionary(
        types.joined().compactMap { type in
            type.hkObjectType.map { ($0.identifier, type) }
        },
        uniquingKeysWith: { first, _ in first }
    )
}()

public extension String {
    @available(*, deprecated, message: "Not HealthKit specific; will be removed from the public API")
    var integer: Int? {
        return Int(self)
    }
    @available(*, deprecated, message: "Not HealthKit specific; will be removed from the public API")
    var double: Double? {
        return Double(self)
    }
    @available(*, deprecated, message: "Not HealthKit specific; will be removed from the public API")
    var boolean: Bool {
        return (self as NSString).boolValue
    }
    /// The wrapped **ObjectType** with this HealthKit identifier, or nil
    var objectType: ObjectType? {
        return objectTypesByIdentifier[self]
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
