//
//  SampleType.swift
//  HealthKitReporter
//
//  Created by Quentin on 01.08.24.
//

import HealthKit

public enum ClinicalType: Int, CaseIterable, SampleType {
    case allergyRecord
    case conditionRecord
    case immunizationRecord
    case labResultRecord
    case medicationRecord
    case procedureRecord
    case vitalSignRecord
    case coverageRecord
    case clinicalNoteRecord
    
    public var identifier: String? {
        return original?.identifier
    }
    
    public var original: HKObjectType? {
        switch self {
        case .allergyRecord:
            return HKObjectType.clinicalType(forIdentifier: .allergyRecord)
        case .conditionRecord:
            return HKObjectType.clinicalType(forIdentifier: .conditionRecord)
        case .immunizationRecord:
            return HKObjectType.clinicalType(forIdentifier: .immunizationRecord)
        case .labResultRecord:
            return HKObjectType.clinicalType(forIdentifier: .labResultRecord)
        case .medicationRecord:
            return HKObjectType.clinicalType(forIdentifier: .medicationRecord)
        case .procedureRecord:
            return HKObjectType.clinicalType(forIdentifier: .procedureRecord)
        case .vitalSignRecord:
            return HKObjectType.clinicalType(forIdentifier: .vitalSignRecord)
        case .coverageRecord:
            return HKObjectType.clinicalType(forIdentifier: .coverageRecord)
        case .clinicalNoteRecord:
            if #available(iOS 16.4, watchOS 9.4, *) {
                return HKObjectType.clinicalType(forIdentifier: .clinicalNoteRecord)
            }
            return nil
        }
    }
}
