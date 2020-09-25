//
//  Extensions+HKWorkout.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

extension HKWorkout {
    typealias Parsable = Workout

    func energyBurned() throws -> (value: Double, unit: String) {
        guard let energyBurned = self.totalEnergyBurned?.doubleValue(for: HKUnit.largeCalorie()) else {
            throw HealthKitError.invalidValue(<#T##String#>)
        }
    }

}
