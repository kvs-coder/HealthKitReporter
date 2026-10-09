//
//  Extensions+HKWorkoutEvent.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

// MARK: - Harmonizable
extension HKWorkoutEvent: Harmonizable {
    typealias Harmonized = WorkoutEvent.Harmonized

    func harmonize() throws -> Harmonized {
        return Harmonized(
            value: type.rawValue,
            description: type.label,
            metadata: metadata?.asMetadata
        )
    }
}
// MARK: - Parsing
extension HKWorkoutEvent {
    /// Names the event in errors: its type and start date
    var parsingName: String {
        return "\(type.label) workout event at \(dateInterval.start)"
    }
}
