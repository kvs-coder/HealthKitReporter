//
//  Extensions+HKHeartbeatSeriesSample.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 12.10.21.
//

import HealthKit

@available(iOS 13.0, *)
extension HKHeartbeatSeriesSample {
    typealias Harmonized = HeartbeatSeries.Harmonized
    
    func harmonize(measurements: [HeartbeatSeries.Measurement]) -> Harmonized {
        Harmonized(
            count: count,
            measurements: measurements,
            metadata: metadata?.asMetadata
        )
    }
}
