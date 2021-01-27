//
//  Extensions+HKWorkoutEvent.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

extension HKWorkoutEvent: Harmonizable {
    typealias Harmonized = WorkoutEvent.Harmonized

    func harmonize() throws -> Harmonized {
        return Harmonized(
            value: type.rawValue,
            metadata: metadata?.compactMapValues { String(describing: $0 )})
    }
}
