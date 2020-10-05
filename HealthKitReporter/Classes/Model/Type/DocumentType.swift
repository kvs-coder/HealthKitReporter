//
//  DocumentType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum DocumentType: Int, Original {
    public typealias Object = HKDocumentType

    case cda

    func asOriginal() throws -> Object {
        switch self {
        case .cda:
            return HKObjectType.documentType(forIdentifier: .CDA)!
        }
    }
}
