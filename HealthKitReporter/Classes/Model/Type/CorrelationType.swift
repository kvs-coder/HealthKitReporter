//
//  CorrelationType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum CorrelationType: Int, CaseIterable, ObjectType {
    case bloodPressure
    case food

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .food:
            return HKObjectType.correlationType(forIdentifier: .food)
        case .bloodPressure:
            return HKObjectType.correlationType(forIdentifier: .bloodPressure)
        }
    }
}
