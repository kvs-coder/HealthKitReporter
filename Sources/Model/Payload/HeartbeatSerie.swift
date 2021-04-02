//
//  HeartbeatSerie.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation

public struct HeartbeatSerie: Codable {
    public let timeSinceSeriesStart: Double
    public let precededByGap: Bool
    public let done: Bool

    public init(
        timeSinceSeriesStart: Double,
        precededByGap: Bool,
        done: Bool
    ) {
        self.timeSinceSeriesStart = timeSinceSeriesStart
        self.precededByGap = precededByGap
        self.done = done
    }
}
