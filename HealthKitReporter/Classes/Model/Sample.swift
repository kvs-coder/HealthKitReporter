//
//  Sample.swift
//  HealthKitReporter
//
//  Created by Florian on 14.09.20.
//

import Foundation
import HealthKit

public protocol Sample: Codable {
    var identifier: String { get }
}
