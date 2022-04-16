//
//  Extensions+HKActivitySummary.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import HealthKit

@available(iOS 9.3, *)
extension HKActivitySummary: Harmonizable {
    typealias Harmonized = ActivitySummary.Harmonized

    func harmonize() throws -> Harmonized {
        let activeEnergyBurnedUnit: HKUnit
        if #available(iOS 11.0, *) {
            activeEnergyBurnedUnit = HKUnit.largeCalorie()
        } else {
            activeEnergyBurnedUnit = HKUnit.kilocalorie()
        }
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
