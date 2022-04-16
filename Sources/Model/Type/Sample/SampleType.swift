//
//  SampleType.swift
//  HealthKitReporter
//
//  Created by Victor on 18.11.20.
//

import HealthKit

public protocol SampleType: ObjectType {
    /**
     Extracts an original identifier
     */
    var identifier: String? { get }
}
