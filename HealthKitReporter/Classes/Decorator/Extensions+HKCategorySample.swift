//
//  Extensions+HKCategoryself.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import Foundation
import HealthKit

extension HKCategorySample: Harmonizable {
    public struct Harmonized: Codable {
        let value: Int
        let description: String
        let metadata: [String: String]?
    }

    func harmonize() throws -> Harmonized {
        if #available(iOS 13.0, *) {
            if self.categoryType == HKObjectType.categoryType(forIdentifier: .audioExposureEvent) {
                if let value = HKCategoryValueAudioExposureEvent(rawValue: self.value) {
                    return category(description: String(describing: value))
                }
            }
        }
        switch self.categoryType {
        case HKObjectType.categoryType(forIdentifier: .sleepAnalysis):
            if let value = HKCategoryValueSleepAnalysis(rawValue: self.value) {
                return category(description: String(describing: value))
            }
        case HKObjectType.categoryType(forIdentifier: .sexualActivity):
            if let metadata = self.metadata?[HKMetadataKeySexualActivityProtectionUsed] as? Int {
                switch metadata {
                case 1:
                    return category(description: "protectionUsed")
                case 2:
                    return category(description: "protectionNotUsed")
                default:
                    return category(description: "unspecified")
                }
            }
        case HKObjectType.categoryType(forIdentifier: .menstrualFlow):
            if let value = HKCategoryValueMenstrualFlow(rawValue: self.value) {
                return category(description: String(describing: value))
            }
        case HKObjectType.categoryType(forIdentifier: .ovulationTestResult):
            if let value = HKCategoryValueOvulationTestResult(rawValue: self.value) {
                return category(description: String(describing: value))
            }
        case HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality):
            if let value = HKCategoryValueCervicalMucusQuality(rawValue: self.value) {
                return category(description: String(describing: value))
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

    private func category(description: String) -> Harmonized {
        return Harmonized(
            value: self.value,
            description: description,
            metadata: self.metadata?.compactMapValues { String(describing: $0 )}
        )
    }
}
