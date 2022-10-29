//
//  Extensions+HKWorkoutEvent.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

extension HKWorkoutEvent: Harmonizable {
    typealias Harmonized = WorkoutEvent.Harmonized

    func harmonize() throws -> Harmonized {
        if #available(iOS 10.0, *) {
            return Harmonized(
                value: type.rawValue,
                description: type.description,
                metadata: metadata?.asMetadata
            )
        } else {
            throw HealthKitError.notAvailable(
                "Metadata is not available for the current iOS"
            )
        }
    }
}
