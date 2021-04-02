//
//  UnitConvertable.swift
//  
//
//  Created by Vignesh J on 16/02/21.
//

import Foundation
import HealthKit

public protocol UnitConvertable {
    func converted(to unit: String) throws -> Self
}
