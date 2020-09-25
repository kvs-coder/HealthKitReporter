//
//  HeartbeatSerie.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

public struct HeartbeatSerie: Codable {
    public let ibiArray: [Double]
    public let indexArray: [Int]
}
