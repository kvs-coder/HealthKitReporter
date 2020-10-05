//
//  SeriesType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum SeriesType: Int, OriginalType {
    case heartbeatSeries
    case route

    var original: HKSeriesType? {
        switch self {
        case .heartbeatSeries:
            if #available(iOS 13.0, *) {
                return HKObjectType.seriesType(forIdentifier: HKDataTypeIdentifierHeartbeatSeries)
            } else {
                return nil
            }
        case .route:
            return HKObjectType.seriesType(forIdentifier: HKWorkoutRouteTypeIdentifier)
        }
    }
}
