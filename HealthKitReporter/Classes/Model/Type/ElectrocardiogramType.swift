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
    public typealias Object = HKElectrocardiogramType

    case electrocardiogramType

    var original: Object? {
        switch self {
        case .electrocardiogramType:
            return HKObjectType.electrocardiogramType()
        }
    }
}
