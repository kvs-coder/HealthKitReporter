//
//  Extensions+HKWorkout.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

extension HKWorkout: Harmonizable {
    typealias Harmonized = Workout.Harmonized

    func harmonize() throws -> Harmonized {
        let totalEnergyBurnedUnit = HKUnit.largeCalorie()
        guard
            let totalEnergyBurned = totalEnergyBurned?.doubleValue(for: totalEnergyBurnedUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalEnergyBurned value for HKWorkout")
        }
        let totalDistanceUnit = HKUnit.meter()
        guard
            let totalDistance = totalDistance?.doubleValue(for: totalDistanceUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalDistance value for HKWorkout")
        }
        let countUnit = HKUnit.count()
        guard
            let totalSwimmingStrokeCount = totalSwimmingStrokeCount?.doubleValue(for: countUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalDistance value for HKWorkout")
        }
        guard
            let totalFlightsClimbed = totalFlightsClimbed?.doubleValue(for: countUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalDistance value for HKWorkout")
        }
        return Harmonized(
            value: Int(workoutActivityType.rawValue),
            totalEnergyBurned: totalEnergyBurned,
            totalEnergyBurnedUnit: totalEnergyBurnedUnit.unitString,
            totalDistance: totalDistance,
            totalDistanceUnit: totalDistanceUnit.unitString,
            totalSwimmingStrokeCount: totalSwimmingStrokeCount,
            totalSwimmingStrokeCountUnit: countUnit.unitString,
            totalFlightsClimbed: totalFlightsClimbed,
            totalFlightsClimbedUnit: countUnit.unitString,
            metadata: metadata?.compactMapValues { String(describing: $0 )}
        )
    }
}
