//
//  VisionPrescriptionType.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 04.10.22.
//

import HealthKit

/**
 All HealthKit vision prescription types
 */
public enum VisionPrescriptionType: Int, CaseIterable, SampleType {
    case visionPrescription

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .visionPrescription:
            if #available(iOS 16.0, *) {
                return HKObjectType.visionPrescriptionType()
            }
        }
        return nil
    }
}
