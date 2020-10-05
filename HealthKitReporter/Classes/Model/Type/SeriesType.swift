//
//  SeriesType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

public enum SeriesType: Int, Original {
    public typealias Object = HKSeriesType

    case heartbeatSeries
    case route

    func asOriginal() throws -> Object {
        switch self {
        case .heartbeatSeries:
            if #available(iOS 13.0, *) {
                return HKObjectType.seriesType(forIdentifier: HKDataTypeIdentifierHeartbeatSeries)!
            } else {
                throw HealthKitError.notAvailable(
                    "Not available in iOS lower than iOS 13.0"
                )
            }
        case .route:
            return HKObjectType.seriesType(forIdentifier: HKWorkoutRouteTypeIdentifier)!
        }
    }
}
