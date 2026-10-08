//
//  CharacteristicType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import HealthKit

/**
 All HealthKit characteristic types
 */
public enum CharacteristicType: Int, CaseIterable, ObjectType {
    case fitzpatrickSkinType
    case dateOfBirth
    case bloodType
    case biologicalSex
    case wheelchairUse
    case activityMoveMode

    public var identifier: String? {
        return original?.identifier
    }

    var original: HKObjectType? {
        switch self {
        case .fitzpatrickSkinType:
            return  HKObjectType.characteristicType(forIdentifier: .fitzpatrickSkinType)
        case .dateOfBirth:
            return HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
        case .bloodType:
            return HKObjectType.characteristicType(forIdentifier: .bloodType)
        case .biologicalSex:
            return HKObjectType.characteristicType(forIdentifier: .biologicalSex)
        case .wheelchairUse:
            return HKObjectType.characteristicType(forIdentifier: .wheelchairUse)
        case .activityMoveMode:
            return HKObjectType.characteristicType(forIdentifier: .activityMoveMode)
        }
    }
}
// MARK: - HealthKitObjectTypeConvertible
extension CharacteristicType: HealthKitObjectTypeConvertible {}
