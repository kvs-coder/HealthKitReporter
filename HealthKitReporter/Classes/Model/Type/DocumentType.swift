//
//  DocumentType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

/**
 All HealthKit document types
 */
public enum DocumentType: Int, CaseIterable, ObjectType {
    case cda

    public var original: HKObjectType? {
        switch self {
        case .cda:
            return HKObjectType.documentType(forIdentifier: .CDA)
        }
    }
}
