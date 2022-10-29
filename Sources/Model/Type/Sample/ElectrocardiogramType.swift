//
//  ElectrocardiogramType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import HealthKit

/**
 All HealthKit electrocardiogram types
 */
public enum ElectrocardiogramType: Int, CaseIterable, SampleType {
    case electrocardiogramType

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .electrocardiogramType:
            if #available(iOS 14.0, *) {
                return HKObjectType.electrocardiogramType()
            }
        }
        return nil
    }
}
