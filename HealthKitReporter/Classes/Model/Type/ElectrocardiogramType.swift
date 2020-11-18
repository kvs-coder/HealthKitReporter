//
//  ElectrocardiogramType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

/**
 All HealthKit electrocardiogram types
 */
@available(iOS 14.0, *)
public enum ElectrocardiogramType: Int, CaseIterable, ObjectType {
    case electrocardiogramType

    public var original: HKObjectType? {
        switch self {
        case .electrocardiogramType:
            return HKObjectType.electrocardiogramType()
        }
    }
}
