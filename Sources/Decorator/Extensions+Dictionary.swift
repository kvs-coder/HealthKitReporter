//
//  Extensions+Dictionary.swift
//  HealthKitReporter
//
//  Created by Victor on 13.11.20.
//

import HealthKit

extension Dictionary where Key == String, Value == NSPredicate {
    /// The predicates by sample type; an identifier naming no sample type throws HealthKitError.invalidType
    func sampleTypePredicates() throws -> [HKSampleType: NSPredicate] {
        var samplePredicates = [HKSampleType: NSPredicate]()
        for (key, value) in self {
            guard let type = key.objectType?.hkObjectType as? HKSampleType else {
                throw HealthKitError.invalidType("\(key) is not a sample type identifier")
            }
            samplePredicates[type] = value
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
