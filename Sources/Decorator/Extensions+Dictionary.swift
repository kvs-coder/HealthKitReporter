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
    /// The number at the key as an **Int**, whichever numeric type the dictionary holds
    func int(_ key: String) -> Int? {
        return (self[key] as? NSNumber).map(Int.init(truncating:))
    }
    /// The number at the key as a **Bool**, whether the dictionary holds a Bool or 0 / 1
    func bool(_ key: String) -> Bool? {
        return (self[key] as? NSNumber)?.boolValue
    }
    /// HealthKit metadata as **Metadata**. A value no **Metadata.Value** can express is skipped on its own,
    /// so one unreadable metadata field doesn't hide the sample it describes (ADR 0002)
    var asMetadata: Metadata? {
        return Metadata(compactMapValues { Metadata.Value($0) })
    }
}
