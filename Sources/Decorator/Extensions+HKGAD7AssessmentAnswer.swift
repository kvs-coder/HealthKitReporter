//
//  Extensions+HKGAD7AssessmentAnswer.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09.10.26.
//

import HealthKit

@available(iOS 18.0, watchOS 11.0, *)
extension HKGAD7Assessment.Answer {
    /// Not at all through nearly every day; Swift accepts any raw value, HealthKit doesn't
    init(knownRawValue rawValue: Int) throws {
        guard (0...3).contains(rawValue), let value = HKGAD7Assessment.Answer(rawValue: rawValue) else {
            throw HealthKitError.invalidValue("Unknown GAD-7 answer: \(rawValue)")
        }
        self = value
    }
}
