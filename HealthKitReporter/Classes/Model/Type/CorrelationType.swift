//
//  CorrelationType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum CorrelationType: Int, ObjectType {
    case bloodPressure
    case food

    public var original: HKCorrelationType? {
        switch self {
        case .food:
            return HKObjectType.correlationType(forIdentifier: .food)
        case .bloodPressure:
            return HKObjectType.correlationType(forIdentifier: .bloodPressure)
        }
    }
}
