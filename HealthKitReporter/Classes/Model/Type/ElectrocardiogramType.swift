//
//  ElectrocardiogramType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

@available(iOS 14.0, *)
public enum ElectrocardiogramType: Int, Original {
    public typealias Object = HKElectrocardiogramType

    case electrocardiogram

    func asOriginal() throws -> Object {
        switch self {
        case .electrocardiogram:
            return HKObjectType.electrocardiogramType()
        }
    }
}
