//
//  ScoredAssessmentType.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/**
 All HealthKit scored assessment types
 */
public enum ScoredAssessmentType: Int, CaseIterable, SampleType {
    /// GAD-7 anxiety assessment
    case gad7
    /// PHQ-9 depression assessment
    case phq9

    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        guard #available(iOS 18.0, watchOS 11.0, *) else {
            return nil
        }
        switch self {
        case .gad7:
            return HKScoredAssessmentType(.GAD7)
        case .phq9:
            return HKScoredAssessmentType(.PHQ9)
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension ScoredAssessmentType: HealthKitObjectTypeConvertible {}
