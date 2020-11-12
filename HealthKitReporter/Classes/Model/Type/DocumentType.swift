//
//  DocumentType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum DocumentType: Int, CaseIterable, ObjectType {
    case cda

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .cda:
            return HKObjectType.documentType(forIdentifier: .CDA)
        }
    }
}
