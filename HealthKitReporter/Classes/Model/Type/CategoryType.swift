//
//  CategoryType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

/**
 All HealthKit category types
 */
public enum CategoryType: Int, CaseIterable, ObjectType {
    case sleepAnalysis
    case appleStandHour
    case sexualActivity
    case intermenstrualBleeding
    case menstrualFlow
    case ovulationTestResult
    case cervicalMucusQuality
    case audioExposureEvent

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .sleepAnalysis:
            return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case .appleStandHour:
            return HKObjectType.categoryType(forIdentifier: .appleStandHour)
        case .sexualActivity:
            return HKObjectType.categoryType(forIdentifier: .sexualActivity)
        case .intermenstrualBleeding:
            return HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding)
        case .menstrualFlow:
            return HKObjectType.categoryType(forIdentifier: .menstrualFlow)
        case .ovulationTestResult:
            return HKObjectType.categoryType(forIdentifier: .ovulationTestResult)
        case .cervicalMucusQuality:
            return HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality)
        case .audioExposureEvent:
            if #available(iOS 13.0, *) {
                return HKObjectType.categoryType(forIdentifier: .audioExposureEvent)
            } else {
                return nil
            }
        }
    }
}
