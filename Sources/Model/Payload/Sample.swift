//
//  Sample.swift
//  HealthKitReporter
//
//  Created by Victor on 14.09.20.
//

import Foundation

/// **Sample** a payload HealthKit stores; `uuid` names the stored sample, `identifier` its sample type
public protocol Sample: Codable {
    var uuid: String { get }
    var identifier: String { get }
    var startTimestamp: Double { get }
    var endTimestamp: Double { get }
}
