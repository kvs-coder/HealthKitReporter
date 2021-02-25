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
        let totalEnergyBurned = self.totalEnergyBurned?.doubleValue(for: totalEnergyBurnedUnit) ?? 0
        let totalDistanceUnit = HKUnit.meter()
        let totalDistance = self.totalDistance?.doubleValue(for: totalDistanceUnit) ?? 0
        let countUnit = HKUnit.count()
        let totalSwimmingStrokeCount = self.totalSwimmingStrokeCount?.doubleValue(for: countUnit) ?? 0
        let totalFlightsClimbed = self.totalFlightsClimbed?.doubleValue(for: countUnit) ?? 0
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
