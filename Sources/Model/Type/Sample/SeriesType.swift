//
//  SeriesType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import HealthKit

/**
 All HealthKit series types
 */
public enum SeriesType: Int, CaseIterable, SampleType {
    case heartbeatSeries
    case workoutRoute

    /// The HealthKit identifier of the type; nil when the type is not available on the running OS
    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        switch self {
        case .heartbeatSeries:
            let heartbeatSeries = HKObjectType.seriesType(
                forIdentifier: HKDataTypeIdentifierHeartbeatSeries
            )
            return heartbeatSeries ?? HKSeriesType.heartbeat()
        case .workoutRoute:
            let workoutRoute = HKObjectType.seriesType(
                forIdentifier: HKWorkoutRouteTypeIdentifier
            )
            return workoutRoute ?? HKSeriesType.workoutRoute()
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension SeriesType: HealthKitObjectTypeConvertible {}
