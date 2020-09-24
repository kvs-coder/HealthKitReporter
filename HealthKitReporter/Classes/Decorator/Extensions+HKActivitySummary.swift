//
//  Extensions+HKActivitySummary.swift
//  HealthKitReporter
//
//  Created by Florian on 24.09.20.
//

import Foundation
import HealthKit

extension HKActivitySummary {
    func activeEnergyBurned() -> (value: Double, goal: Double, unit: String) {
        let unit = HKUnit.largeCalorie()
        let value = self.activeEnergyBurned.doubleValue(for: unit)
        let goal = self.activeEnergyBurnedGoal.doubleValue(for: unit)
        return (value, goal, unit.unitString)
    }
    func appleExerciseTime() -> (value: Double, goal: Double, unit: String) {
        let unit = HKUnit.minute()
        let value = self.appleExerciseTime.doubleValue(for: unit)
        let goal = self.appleExerciseTimeGoal.doubleValue(for: unit)
        return (value, goal, unit.unitString)
    }
    func appleStandHours() -> (value: Double, goal: Double, unit: String) {
        let unit = HKUnit.count()
        let value = self.appleStandHours.doubleValue(for: unit)
        let goal = self.appleStandHoursGoal.doubleValue(for: unit)
        return (value, goal, unit.unitString)
    }
}
