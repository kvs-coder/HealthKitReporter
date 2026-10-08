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
            if let type = key.objectType?.original as? HKSampleType {
                samplePredicates[type] = value
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
