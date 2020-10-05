//
//  ObjectType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public protocol ObjectType {
    associatedtype SampleType where SampleType: HKObjectType

    var original: SampleType? { get }
}
