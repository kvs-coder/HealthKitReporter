//
//  CorrelationType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum CorrelationType: Int, Original {
    public typealias Object = HKCorrelationType
    
    case bloodPressure
    case food

    func asOriginal() throws -> Object {
        switch self {
        case .food:
            return HKObjectType.correlationType(forIdentifier: .food)!
        case .bloodPressure:
            return HKObjectType.correlationType(forIdentifier: .bloodPressure)!
        }
    }
}
