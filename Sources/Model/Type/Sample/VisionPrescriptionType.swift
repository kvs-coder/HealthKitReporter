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

    /// The HealthKit identifier of the type; nil when the type is not available on the running OS
    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        switch self {
        case .visionPrescription:
            if #available(iOS 16.0, watchOS 9.0, *) {
                return HKObjectType.visionPrescriptionType()
            }
        }
        return nil
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension VisionPrescriptionType: HealthKitObjectTypeConvertible {}
