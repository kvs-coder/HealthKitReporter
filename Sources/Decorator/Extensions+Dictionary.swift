//
//  Extensions+Dictionary.swift
//  HealthKitReporter
//
//  Created by Victor on 13.11.20.
//

import HealthKit

public extension Dictionary where Key == String, Value == NSPredicate {
    var sampleTypePredicates: [HKSampleType: NSPredicate] {
        var samplePredicates = [HKSampleType: NSPredicate]()
        for (key, value) in self {
            if let type = try? QuantityType.make(from: key)
                .original as? HKSampleType {
                samplePredicates[type] = value
            }
            if let type = try? CategoryType.make(from: key)
                .original as? HKSampleType {
                samplePredicates[type] = value
            }
            if let type = try? CharacteristicType.make(from: key)
                .original as? HKSampleType {
                samplePredicates[type] = value
            }
            if let type = try? SeriesType.make(from: key)
                .original as? HKSampleType {
                samplePredicates[type] = value
            }
            if let type = try? CorrelationType.make(from: key)
                .original as? HKSampleType {
                samplePredicates[type] = value
            }
            if let type = try? DocumentType.make(from: key)
                .original as? HKSampleType {
                samplePredicates[type] = value
            }
            if let type = try? ActivitySummaryType.make(from: key)
                .original as? HKSampleType {
                samplePredicates[type] = value
            }
            if let type = try? WorkoutType.make(from: key)
                .original as? HKSampleType {
                samplePredicates[type] = value
            }
            if #available(iOS 14.0, *) {
                if let type = try? ElectrocardiogramType.make(from: key)
                    .original as? HKSampleType {
                    samplePredicates[type] = value
                }
            }
        }
        return samplePredicates
    }
}

public extension Dictionary where Key == String, Value == Any {
    var asMetadata: Metadata? {
        try? Metadata.make(from: self)
    }
}
