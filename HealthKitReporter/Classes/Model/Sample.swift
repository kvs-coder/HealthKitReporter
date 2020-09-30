//
//  Sample.swift
//  HealthKitReporter
//
//  Created by Victor on 14.09.20.
//

import Foundation
import HealthKit

public protocol Sample: Codable {
    var startDate: String { get }
    var endDate: String { get }
}
