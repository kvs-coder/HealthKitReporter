//
//  Characteristics.swift
//  HealthKitReporter
//
//  Created by KVS on 25.09.20.
//

import Foundation
import HealthKit

public struct Characteristics: Codable {
    public let biologicalSex: String
    public let birthday: String?
    public let bloodType: String
    public let skinType: String

    public init(
        biologicalSex: HKBiologicalSexObject,
        birthday: DateComponents,
        bloodType: HKBloodTypeObject,
        skinType: HKFitzpatrickSkinTypeObject
    ) {
        self.biologicalSex = biologicalSex.biologicalSex.string
        self.birthday = birthday.date?.formatted(with: Date.yyyyMMdd)
        self.bloodType = bloodType.bloodType.string
        self.skinType = skinType.skinType.string
    }
}
