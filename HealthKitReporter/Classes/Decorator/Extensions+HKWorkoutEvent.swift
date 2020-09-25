//
//  Extensions+HKWorkoutEvent.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

extension HKWorkoutEvent: HealthKitHarmonizable {
    public struct Harmonized: Codable {
        let metadata: [String: String]?
    }

    func harmonize() throws -> Harmonized {
        return Harmonized(metadata: self.metadata?.compactMapValues { String(describing: $0 )})
    }
}
