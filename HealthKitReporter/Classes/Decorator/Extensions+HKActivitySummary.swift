//
//  Extensions+HKActivitySummary.swift
//  HealthKitReporter
//
//  Created by KVS on 24.09.20.
//

import Foundation
import HealthKit

extension HKActivitySummary: Harmonizable {
    public struct Harmonized: Codable {
        let activeEnergyBurned: Double
        let activeEnergyBurnedGoal: Double
        let activeEnergyBurnedUnit: String
        let appleExerciseTime: Double
        let appleExerciseTimeGoal: Double
        let appleExerciseTimeUnit: String
        let appleStandHours: Double
        let appleStandHoursGoal: Double
        let appleStandHoursUnit: String
    }

    func harmonize() throws -> Harmonized {
        let activeEnergyBurnedUnit = HKUnit.largeCalorie()
        let activeEnergyBurned = self.activeEnergyBurned.doubleValue(for: activeEnergyBurnedUnit)
        let activeEnergyBurnedGoal = self.activeEnergyBurnedGoal.doubleValue(for: activeEnergyBurnedUnit)
        let appleExerciseTimeUnit = HKUnit.minute()
        let appleExerciseTime = self.appleExerciseTime.doubleValue(for: appleExerciseTimeUnit)
        let appleExerciseTimeGoal = self.appleExerciseTimeGoal.doubleValue(for: appleExerciseTimeUnit)
        let appleStandHoursUnit = HKUnit.count()
        let appleStandHours = self.appleStandHours.doubleValue(for: appleStandHoursUnit)
        let appleStandHoursGoal = self.appleStandHoursGoal.doubleValue(for: appleStandHoursUnit)
        return Harmonized(
            activeEnergyBurned: activeEnergyBurned,
            activeEnergyBurnedGoal: activeEnergyBurnedGoal,
            activeEnergyBurnedUnit: activeEnergyBurnedUnit.unitString,
            appleExerciseTime: appleExerciseTime,
            appleExerciseTimeGoal: appleExerciseTimeGoal,
            appleExerciseTimeUnit: appleExerciseTimeUnit.unitString,
            appleStandHours: appleStandHours,
            appleStandHoursGoal: appleStandHoursGoal,
            appleStandHoursUnit: appleStandHoursUnit.unitString
        )
    }
}
