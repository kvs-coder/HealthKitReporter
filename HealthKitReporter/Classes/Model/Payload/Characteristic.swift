//
//  Characteristic.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Characteristic: Codable {
    public let biologicalSex: String?
    public let birthday: String?
    public let bloodType: String?
    public let skinType: String?
    public let wheelchairUse: String?
    public let activityMoveMode: String?
    
    init(
        biologicalSex: HKBiologicalSexObject?,
        birthday: DateComponents?,
        bloodType: HKBloodTypeObject?,
        skinType: HKFitzpatrickSkinTypeObject?,
        wheelchairUse: HKWheelchairUseObject?
    ) {
        self.biologicalSex = biologicalSex?.biologicalSex.string
        self.birthday = birthday?.date?.formatted(with: Date.iso8601)
        self.bloodType = bloodType?.bloodType.string
        self.skinType = skinType?.skinType.string
        self.wheelchairUse = wheelchairUse?.wheelchairUse.string
        self.activityMoveMode = nil
    }
    
    @available(iOS 14.0, *)
    init(
        biologicalSex: HKBiologicalSexObject?,
        birthday: DateComponents?,
        bloodType: HKBloodTypeObject?,
        skinType: HKFitzpatrickSkinTypeObject?,
        wheelchairUse: HKWheelchairUseObject?,
        activityMoveMode: HKActivityMoveModeObject?
    ) {
        self.biologicalSex = biologicalSex?.biologicalSex.string
        self.birthday = birthday?.date?.formatted(with: Date.iso8601)
        self.bloodType = bloodType?.bloodType.string
        self.skinType = skinType?.skinType.string
        self.wheelchairUse = wheelchairUse?.wheelchairUse.string
        self.activityMoveMode = activityMoveMode?.activityMoveMode.string
    }
}
