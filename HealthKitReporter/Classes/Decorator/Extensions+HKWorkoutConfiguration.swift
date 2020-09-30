//
//  Extensions+HKWorkoutConfiguration.swift
//  HealthKitReporter
//
//  Created by KVS on 25.09.20.
//

import Foundation
import HealthKit

extension HKWorkoutConfiguration: Harmonizable {
    public struct Harmonized: Codable {
        let activityValue: Int
        let locationValue: Int
        let swimmingValue: Int
        let value: Double
        let unit: String
    }
    func harmonize() throws -> Harmonized {
        let unit = HKUnit.meter()
        guard let value = self.lapLength?.doubleValue(for: unit) else {
            throw HealthKitError.invalidValue("Value for HKWorkoutConfiguration is invalid")
        }
        return Harmonized(
            activityValue: Int(self.activityType.rawValue),
            locationValue: self.locationType.rawValue,
            swimmingValue: self.swimmingLocationType.rawValue,
            value: value,
            unit: unit.unitString
        )
    }
}
