//
//  DocumentType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum DocumentType: Int, OriginalType {
    public typealias Object = HKDocumentType

    case cda

    var original: Object? {
        switch self {
        case .cda:
            return HKObjectType.documentType(forIdentifier: .CDA)
        }
    }
}
