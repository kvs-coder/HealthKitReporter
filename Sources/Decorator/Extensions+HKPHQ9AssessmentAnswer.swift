//
//  Extensions+HKPHQ9AssessmentAnswer.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09.10.26.
//

import HealthKit

@available(iOS 18.0, watchOS 11.0, *)
extension HKPHQ9Assessment.Answer {
    /// Not at all through nearly every day, or prefer not to answer;
    /// Swift accepts any raw value, HealthKit doesn't
    init(knownRawValue rawValue: Int) throws {
        guard (0...4).contains(rawValue), let value = HKPHQ9Assessment.Answer(rawValue: rawValue) else {
            throw HealthKitError.invalidValue("Unknown PHQ-9 answer: \(rawValue)")
        }
        self = value
    }
}
