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

    public var identifier: String? {
        return original?.identifier
    }
    
    public var original: HKObjectType? {
        switch self {
        case .cda:
            if #available(iOS 10.0, *) {
                return HKObjectType.documentType(forIdentifier: .CDA)
            } else {
                return nil
            }
        }
    }
}
