//
//  HKUnitConvertable.swift
//  
//
//  Created by Vignesh J on 16/02/21.
//

import Foundation
import HealthKit

public protocol HKUnitConvertable {
    func converted(to unit: HKUnit) throws -> Self
}
