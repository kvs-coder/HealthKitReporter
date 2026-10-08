//
//  MedicationType.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/**
 All HealthKit medication types. Medications need per-object read authorization
 */
public enum MedicationType: Int, CaseIterable, ObjectType {
    /// **HKMedicationDoseEvent** samples
    case medicationDoseEvent
    /// medications the user tracks, not samples
    case userAnnotatedMedication

    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        guard #available(iOS 26.0, watchOS 26.0, *) else {
            return nil
        }
        switch self {
        case .medicationDoseEvent:
            return HKObjectType.medicationDoseEventType()
        case .userAnnotatedMedication:
            return HKObjectType.userAnnotatedMedicationType()
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension MedicationType: HealthKitObjectTypeConvertible {}
