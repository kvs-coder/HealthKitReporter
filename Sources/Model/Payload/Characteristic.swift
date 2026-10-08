//
//  Characteristic.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

/// **Characteristic** the user's sex, birthday, blood type, skin type, wheelchair use and move mode
public struct Characteristic: Codable {
    public let biologicalSex: String?
    public let birthday: String?
    public let bloodType: String?
    public let fitzpatrickSkinType: String?
    public let wheelchairUse: String?
    public let activityMoveMode: String?
    
    init(
        biologicalSex: HKBiologicalSexObject?,
        bloodType: HKBloodTypeObject?,
        fitzpatrickSkinType: HKFitzpatrickSkinTypeObject?
    ) {
        self.biologicalSex = biologicalSex?.biologicalSex.label
        self.bloodType = bloodType?.bloodType.label
        self.fitzpatrickSkinType = fitzpatrickSkinType?.skinType.label
        self.birthday = nil
        self.wheelchairUse = nil
        self.activityMoveMode = nil
    }
    
    init(
        biologicalSex: HKBiologicalSexObject?,
        birthday: DateComponents?,
        bloodType: HKBloodTypeObject?,
        fitzpatrickSkinType: HKFitzpatrickSkinTypeObject?,
        wheelchairUse: HKWheelchairUseObject?
    ) {
        self.biologicalSex = biologicalSex?.biologicalSex.label
        self.birthday = birthday?.date?.formatted(with: Date.iso8601)
        self.bloodType = bloodType?.bloodType.label
        self.fitzpatrickSkinType = fitzpatrickSkinType?.skinType.label
        self.wheelchairUse = wheelchairUse?.wheelchairUse.string
        self.activityMoveMode = nil
    }
    
    init(
        biologicalSex: HKBiologicalSexObject?,
        birthday: DateComponents?,
        bloodType: HKBloodTypeObject?,
        fitzpatrickSkinType: HKFitzpatrickSkinTypeObject?,
        wheelchairUse: HKWheelchairUseObject?,
        activityMoveMode: HKActivityMoveModeObject?
    ) {
        self.biologicalSex = biologicalSex?.biologicalSex.label
        self.birthday = birthday?.date?.formatted(with: Date.iso8601)
        self.bloodType = bloodType?.bloodType.label
        self.fitzpatrickSkinType = fitzpatrickSkinType?.skinType.label
        self.wheelchairUse = wheelchairUse?.wheelchairUse.string
        self.activityMoveMode = activityMoveMode?.activityMoveMode.label
    }
}
