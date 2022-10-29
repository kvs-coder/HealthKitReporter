//
//  Extensions+HKWorkoutRoute.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 16.04.22.
//

import HealthKit

@available(iOS 11.0, *)
extension HKWorkoutRoute {
    typealias Harmonized = WorkoutRoute.Harmonized

    func harmonize(routes: [WorkoutRoute.Route]) -> Harmonized {
        Harmonized(
            count: count,
            routes: routes,
            metadata: metadata?.asMetadata
        )
    }
}
