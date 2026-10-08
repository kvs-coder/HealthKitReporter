//
//  DocumentType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import HealthKit

/**
 All HealthKit document types
 */
public enum DocumentType: Int, CaseIterable, SampleType {
    case cda

    /// The HealthKit identifier of the type; nil when the type is not available on the running OS
    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        switch self {
        case .cda:
            return HKObjectType.documentType(forIdentifier: .CDA)
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension DocumentType: HealthKitObjectTypeConvertible {}
