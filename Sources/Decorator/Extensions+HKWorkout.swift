//
//  Extensions+HKWorkout.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

extension HKWorkout: Harmonizable {
    typealias Harmonized = Workout.Harmonized

    func harmonize() throws -> Harmonized {
        let totalEnergyBurnedUnit: HKUnit
        if #available(iOS 11.0, *) {
            totalEnergyBurnedUnit = HKUnit.largeCalorie()
        } else {
            totalEnergyBurnedUnit = HKUnit.kilocalorie()
        }
        let totalEnergyBurned = self.totalEnergyBurned?.doubleValue(for: totalEnergyBurnedUnit)
        
        let totalDistanceUnit = HKUnit.meter()
        let totalDistance = self.totalDistance?.doubleValue(for: totalDistanceUnit)

        let countUnit = HKUnit.count()
        var totalSwimmingStrokeCount: Double?
        if #available(iOS 10.0, *) {
            totalSwimmingStrokeCount = self.totalSwimmingStrokeCount?.doubleValue(for: countUnit)
        }
        var totalFlightsClimbed: Double?
        if #available(iOS 11.0, *) {
            totalFlightsClimbed = self.totalFlightsClimbed?.doubleValue(for: countUnit)
        }
        return Harmonized(
            value: Int(workoutActivityType.rawValue),
            description: workoutActivityType.description,
            totalEnergyBurned: totalEnergyBurned,
            totalEnergyBurnedUnit: totalEnergyBurnedUnit.unitString,
            totalDistance: totalDistance,
            totalDistanceUnit: totalDistanceUnit.unitString,
            totalSwimmingStrokeCount: totalSwimmingStrokeCount,
            totalSwimmingStrokeCountUnit: countUnit.unitString,
            totalFlightsClimbed: totalFlightsClimbed,
            totalFlightsClimbedUnit: countUnit.unitString,
            metadata: metadata?.asMetadata
        )
    }
}
