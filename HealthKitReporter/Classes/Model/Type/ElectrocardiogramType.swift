//
//  ElectrocardiogramType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

@available(iOS 14.0, *)
public enum ElectrocardiogramType: Int, OriginalType {
    case electrocardiogramType

    var original: HKElectrocardiogramType? {
        switch self {
        case .electrocardiogramType:
            return HKObjectType.electrocardiogramType()
        }
    }
}
