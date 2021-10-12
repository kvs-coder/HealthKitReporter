//
//  Extensions+HKHeartbeatSeriesSample.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 12.10.21.
//

import Foundation
import HealthKit

@available(iOS 13.0, *)
extension HKHeartbeatSeriesSample {
    typealias Harmonized = HeartbeatSeriesSample.Harmonized
    
    func harmonize(series: [HeartbeatSeries]) -> Harmonized {
        Harmonized(
            count: count,
            series: series,
            metadata: metadata?.compactMapValues { String(describing: $0) }
        )
    }
}
