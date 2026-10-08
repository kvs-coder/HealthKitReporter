//
//  Extensions+Dictionary.swift
//  HealthKitReporter
//
//  Created by Victor on 13.11.20.
//

import HealthKit

extension Dictionary where Key == String, Value == NSPredicate {
    var sampleTypePredicates: [HKSampleType: NSPredicate] {
        var samplePredicates = [HKSampleType: NSPredicate]()
        for (key, value) in self {
            if let type = key.objectType?.hkObjectType as? HKSampleType {
                samplePredicates[type] = value
            }
        }
        return samplePredicates
    }
}

extension Dictionary where Key == String, Value == Any {
    /// The `uuid` a payload dictionary carries, or a new one when it carries none
    var payloadUUID: String {
        return self["uuid"] as? String ?? UUID().uuidString
    }
}

public extension Dictionary where Key == String, Value == Any {
    /// HealthKit metadata as **Metadata**; values of unsupported types are skipped
    var asMetadata: Metadata? {
        return Metadata(compactMapValues { Metadata.Value($0) })
    }
}
