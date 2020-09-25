//
//  Extensions+HKWorkout.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

extension HKWorkout: HealthKitHarmonizable {
    public struct Harmonized: Codable {
        let totalEnergyBurned: Double?
        let totalEnergyBurnedUnit: String
        let totalDistance: Double?
        let totalDistanceUnit: String
        let totalSwimmingStrokeCount: Double?
        let totalSwimmingStrokeCountUnit: String
        let totalFlightsClimbed: Double?
        let totalFlightsClimbedUnit: String
    }

    func harmonize() throws -> Harmonized {
        let totalEnergyBurnedUnit = HKUnit.largeCalorie()
        guard
            let totalEnergyBurned = self.totalEnergyBurned?.doubleValue(for: totalEnergyBurnedUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalEnergyBurned value for HKWorkout")
        }
        let totalDistanceUnit = HKUnit.meter()
        guard
            let totalDistance = self.totalDistance?.doubleValue(for: totalDistanceUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalDistance value for HKWorkout")
        }
        let countUnit = HKUnit.count()
        guard
            let totalSwimmingStrokeCount = self.totalSwimmingStrokeCount?.doubleValue(for: countUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalDistance value for HKWorkout")
        }
        guard
            let totalFlightsClimbed = self.totalFlightsClimbed?.doubleValue(for: countUnit)
        else {
            throw HealthKitError.invalidValue("Invalid totalDistance value for HKWorkout")
        }
        return Harmonized(
            totalEnergyBurned: totalEnergyBurned,
            totalEnergyBurnedUnit: totalEnergyBurnedUnit.unitString,
            totalDistance: totalDistance,
            totalDistanceUnit: totalDistanceUnit.unitString,
            totalSwimmingStrokeCount: totalSwimmingStrokeCount,
            totalSwimmingStrokeCountUnit: countUnit.unitString,
            totalFlightsClimbed: totalFlightsClimbed,
            totalFlightsClimbedUnit: countUnit.unitString
        )
    }
}
