//
//  Extensions+HKWorkoutConfiguration.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

// MARK: - Harmonizable
extension HKWorkoutConfiguration: Harmonizable {
    typealias Harmonized = WorkoutConfiguration.Harmonized

    func harmonize() throws -> Harmonized {
        let unit = HKUnit.meter()
        guard let value = lapLength?.doubleValue(for: unit) else {
            throw HealthKitError.invalidValue("Value for HKWorkoutConfiguration is invalid")
        }
        return Harmonized(
            value: value,
            unit: unit.unitString
        )
    }
}
// MARK: - Locations
extension HKWorkoutConfiguration {
    /**
     Sets the location and swimming location from their raw values.
     - Parameter location: **Int** raw value of HKWorkoutSessionLocationType
     - Parameter swimmingLocation: **Int** raw value of HKWorkoutSwimmingLocationType
     - Throws: HealthKitError.invalidValue for an unknown value, or for a swimming workout
     that is neither in a pool nor in open water, which HealthKit raises for
     */
    func setLocations(location: Int, swimmingLocation: Int) throws {
        guard let locationType = HKWorkoutSessionLocationType(knownRawValue: location) else {
            throw HealthKitError.invalidValue("Unknown workout location: \(location)")
        }
        guard let swimmingLocationType = HKWorkoutSwimmingLocationType(knownRawValue: swimmingLocation) else {
            throw HealthKitError.invalidValue("Unknown swimming location: \(swimmingLocation)")
        }
        guard activityType != .swimming || swimmingLocationType != .unknown else {
            throw HealthKitError.invalidValue("A swimming workout needs a pool or open water location")
        }
        self.locationType = locationType
        self.swimmingLocationType = swimmingLocationType
    }
}
