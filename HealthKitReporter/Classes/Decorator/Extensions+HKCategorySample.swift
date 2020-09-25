//
//  Extensions+HKCategoryself.swift
//  HealthKitReporter
//
//  Created by Florian on 15.09.20.
//

import Foundation
import HealthKit

extension HKCategorySample: HealthKitHarmonizable {
    struct Harmonized: Codable {
        let description: String
    }

    func harmonize() throws -> Harmonized {
        if #available(iOS 13.0, *) {
            if self.categoryType == HKObjectType.categoryType(forIdentifier: .audioExposureEvent) {
                if let value = HKCategoryValueAudioExposureEvent(rawValue: self.value) {
                    return Harmonized(description: String(describing: value))
                }
            }
        }
        switch self.categoryType {
        case HKObjectType.categoryType(forIdentifier: .sleepAnalysis):
            if let value = HKCategoryValueSleepAnalysis(rawValue: self.value) {
                return Harmonized(description: String(describing: value))
            }
        case HKObjectType.categoryType(forIdentifier: .sexualActivity):
            if let metadata = self.metadata?[HKMetadataKeySexualActivityProtectionUsed] as? Int {
                switch metadata {
                case 1:
                    return Harmonized(description: "protectionUsed")
                case 2:
                    return Harmonized(description: "protectionNotUsed")
                default:
                    return Harmonized(description: "unspecified")
                }
            }
        case HKObjectType.categoryType(forIdentifier: .menstrualFlow):
            if let value = HKCategoryValueMenstrualFlow(rawValue: self.value) {
                return Harmonized(description: String(describing: value))
            }
        case HKObjectType.categoryType(forIdentifier: .ovulationTestResult):
            if let value = HKCategoryValueOvulationTestResult(rawValue: self.value) {
                return Harmonized(description: String(describing: value))
            }
        case HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality):
            if let value = HKCategoryValueCervicalMucusQuality(rawValue: self.value) {
                return Harmonized(description: String(describing: value))
            }
        default:
            throw HealthKitError.invalidType(
                "Invalid type: \(self.categoryType)"
            )
        }
        throw HealthKitError.invalidValue(
            "Invalid value for: \(self.categoryType). Can not be recognized"
        )
    }
}
