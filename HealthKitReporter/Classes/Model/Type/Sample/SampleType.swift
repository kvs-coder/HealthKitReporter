//
//  SampleType.swift
//  HealthKitReporter
//
//  Created by Florian on 18.11.20.
//

import Foundation
import HealthKit

public protocol SampleType: ObjectType {
    /**
     Extracts an original identifier
     */
    var identifier: String? { get }
}
