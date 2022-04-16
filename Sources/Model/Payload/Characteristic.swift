//
//  Characteristic.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

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
        self.biologicalSex = biologicalSex?.biologicalSex.description
        self.bloodType = bloodType?.bloodType.description
        self.fitzpatrickSkinType = fitzpatrickSkinType?.skinType.description
        self.birthday = nil
        self.wheelchairUse = nil
        self.activityMoveMode = nil
    }
    
    @available(iOS 10.0, *)
    init(
        biologicalSex: HKBiologicalSexObject?,
        birthday: DateComponents?,
        bloodType: HKBloodTypeObject?,
        fitzpatrickSkinType: HKFitzpatrickSkinTypeObject?,
        wheelchairUse: HKWheelchairUseObject?
    ) {
        self.biologicalSex = biologicalSex?.biologicalSex.description
        self.birthday = birthday?.date?.formatted(with: Date.iso8601)
        self.bloodType = bloodType?.bloodType.description
        self.fitzpatrickSkinType = fitzpatrickSkinType?.skinType.description
        self.wheelchairUse = wheelchairUse?.wheelchairUse.string
        self.activityMoveMode = nil
    }
    
    @available(iOS 14.0, *)
    init(
        biologicalSex: HKBiologicalSexObject?,
        birthday: DateComponents?,
        bloodType: HKBloodTypeObject?,
        fitzpatrickSkinType: HKFitzpatrickSkinTypeObject?,
        wheelchairUse: HKWheelchairUseObject?,
        activityMoveMode: HKActivityMoveModeObject?
    ) {
        self.biologicalSex = biologicalSex?.biologicalSex.description
        self.birthday = birthday?.date?.formatted(with: Date.iso8601)
        self.bloodType = bloodType?.bloodType.description
        self.fitzpatrickSkinType = fitzpatrickSkinType?.skinType.description
        self.wheelchairUse = wheelchairUse?.wheelchairUse.string
        self.activityMoveMode = activityMoveMode?.activityMoveMode.description
    }
}
