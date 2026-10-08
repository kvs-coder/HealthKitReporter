//
//  ActivitySummary.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

public struct ActivitySummary: Identifiable {
    public struct Harmonized: Codable {
        public let activeEnergyBurned: Double
        public let activeEnergyBurnedGoal: Double
        public let activeEnergyBurnedUnit: String
        public let appleExerciseTime: Double
        public let appleExerciseTimeGoal: Double
        public let appleExerciseTimeUnit: String
        public let appleStandHours: Double
        public let appleStandHoursGoal: Double
        public let appleStandHoursUnit: String
        /// "Active energy" or "Apple move time" (iOS 14+)
        public let activityMoveMode: String?
        /// move time, for wheelchair and youth move goals (iOS 14+)
        public let appleMoveTime: Double?
        public let appleMoveTimeGoal: Double?
        public let appleMoveTimeUnit: String?
        /// the user paused their rings (iOS 18+)
        public let paused: Bool?

        public init(
            activeEnergyBurned: Double,
            activeEnergyBurnedGoal: Double,
            activeEnergyBurnedUnit: String,
            appleExerciseTime: Double,
            appleExerciseTimeGoal: Double,
            appleExerciseTimeUnit: String,
            appleStandHours: Double,
            appleStandHoursGoal: Double,
            appleStandHoursUnit: String,
            activityMoveMode: String? = nil,
            appleMoveTime: Double? = nil,
            appleMoveTimeGoal: Double? = nil,
            appleMoveTimeUnit: String? = nil,
            paused: Bool? = nil
        ) {
            self.activeEnergyBurned = activeEnergyBurned
            self.activeEnergyBurnedGoal = activeEnergyBurnedGoal
            self.activeEnergyBurnedUnit = activeEnergyBurnedUnit
            self.appleExerciseTime = appleExerciseTime
            self.appleExerciseTimeGoal = appleExerciseTimeGoal
            self.appleExerciseTimeUnit = appleExerciseTimeUnit
            self.appleStandHours = appleStandHours
            self.appleStandHoursGoal = appleStandHoursGoal
            self.appleStandHoursUnit = appleStandHoursUnit
            self.activityMoveMode = activityMoveMode
            self.appleMoveTime = appleMoveTime
            self.appleMoveTimeGoal = appleMoveTimeGoal
            self.appleMoveTimeUnit = appleMoveTimeUnit
            self.paused = paused
        }
    }

    public let identifier: String
    public let date: String?
    public let harmonized: Harmonized

    init(activitySummary: HKActivitySummary) throws {
        self.identifier = ActivitySummaryType
            .activitySummaryType
            .original?
            .identifier ?? "HKActivitySummaryTypeIdentifier"
        self.date = activitySummary
            .dateComponents(for: Calendar.current)
            .date?
            .formatted(with: Date.iso8601)
        self.harmonized = try activitySummary.harmonize()
    }
}
