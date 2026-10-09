//
//  Extensions+HKActivitySummary.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import HealthKit

// MARK: - Harmonizable
extension HKActivitySummary: Harmonizable {
    typealias Harmonized = ActivitySummary.Harmonized

    func harmonize() throws -> Harmonized {
        let activeEnergyBurnedUnit = HKUnit.largeCalorie()
        let minuteUnit = HKUnit.minute()
        let countUnit = HKUnit.count()
        var exerciseGoal = appleExerciseTimeGoal
        var standGoal = appleStandHoursGoal
        if #available(iOS 16.0, watchOS 9.0, *) {
            exerciseGoal = exerciseTimeGoal ?? exerciseGoal
            standGoal = standHoursGoal ?? standGoal
        }
        var paused: Bool?
        if #available(iOS 18.0, watchOS 11.0, *) {
            paused = isPaused
        }
        return Harmonized(
            activeEnergyBurned: activeEnergyBurned.doubleValue(for: activeEnergyBurnedUnit),
            activeEnergyBurnedGoal: activeEnergyBurnedGoal.doubleValue(for: activeEnergyBurnedUnit),
            activeEnergyBurnedUnit: activeEnergyBurnedUnit.unitString,
            appleExerciseTime: appleExerciseTime.doubleValue(for: minuteUnit),
            appleExerciseTimeGoal: exerciseGoal.doubleValue(for: minuteUnit),
            appleExerciseTimeUnit: minuteUnit.unitString,
            appleStandHours: appleStandHours.doubleValue(for: countUnit),
            appleStandHoursGoal: standGoal.doubleValue(for: countUnit),
            appleStandHoursUnit: countUnit.unitString,
            activityMoveMode: activityMoveMode.label,
            appleMoveTime: appleMoveTime.doubleValue(for: minuteUnit),
            appleMoveTimeGoal: appleMoveTimeGoal.doubleValue(for: minuteUnit),
            appleMoveTimeUnit: minuteUnit.unitString,
            paused: paused
        )
    }
}
// MARK: - Parsing
extension HKActivitySummary {
    /// Names the summary in errors: its day
    var parsingName: String {
        return "activity summary of \(dateComponents(for: Calendar.current))"
    }
}
