//
//  QueryDescriptor.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// One sample type and predicate of a query that reads several types at once
public struct QueryDescriptor {
    public let type: SampleType
    public let predicate: NSPredicate?

    /// Creates the **QueryDescriptor** from its fields
    public init(type: SampleType, predicate: NSPredicate? = nil) {
        self.type = type
        self.predicate = predicate
    }
}
// MARK: - Original
extension QueryDescriptor: Original {
    func asOriginal() throws -> HKQueryDescriptor {
        guard let sampleType = type.hkObjectType as? HKSampleType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKSampleType")
        }
        return HKQueryDescriptor(sampleType: sampleType, predicate: predicate)
    }
}
