//
//  Extensions+HKCategoryself.swift
//  HealthKitReporter
//
//  Created by Florian on 15.09.20.
//

import Foundation
import HealthKit

extension HKCategorySample {
    func parsed() throws -> (value: Double, status: String) {
        if #available(iOS 13.0, *) {
            if self.categoryType == HKObjectType.categoryType(forIdentifier: .audioExposureEvent) {
                if let value = HKCategoryValueAudioExposureEvent(rawValue: self.value) {
                    switch value {
                    case .loudEnvironment:
                        return (Double(self.value), "loudEnvironment")
                    }
                }
            }
        }
        switch self.categoryType {
        case HKObjectType.categoryType(forIdentifier: .sleepAnalysis):
            if let sleepAnalisis = HKCategoryValueSleepAnalysis(rawValue: self.value) {
                switch sleepAnalisis {
                case .inBed:
                    return (Double(0), "inBed")
                case .asleep:
                    return (Double(1), "asleep")
                case .awake:
                    return (Double(2), "awake")
                }
            }
        case HKObjectType.categoryType(forIdentifier: .sexualActivity):
            if let metadata = self.metadata?[HKMetadataKeySexualActivityProtectionUsed] as? Int {
                switch metadata {
                case 1:
                    return (Double(1), "protectionUsed")
                case 2:
                    return (Double(2), "protectionNotUsed")
                default:
                    return (Double(3), "unspecified")
                }
            }
        case HKObjectType.categoryType(forIdentifier: .menstrualFlow):
            if let value = HKCategoryValueMenstrualFlow(rawValue: self.value) {
                switch value {
                case .unspecified:
                    return (Double(1), "unspecified")
                case .light:
                    return (Double(2), "light")
                case .medium:
                    return (Double(3), "medium")
                case .heavy:
                    return (Double(4), "heavy")
                case .none:
                    return (Double(5), "none")
                }
            }
        case HKObjectType.categoryType(forIdentifier: .ovulationTestResult):
            if let value = HKCategoryValueOvulationTestResult(rawValue: self.value) {
                switch value {
                case .negative:
                    return (Double(1), "negative")
                case .luteinizingHormoneSurge:
                    return (Double(2), "luteinizingHormoneSurge")
                case .indeterminate:
                    return (Double(3), "indeterminate")
                case .estrogenSurge:
                    return (Double(4), "estrogenSurge")
                }
            }
        case HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality):
            if let value = HKCategoryValueCervicalMucusQuality(rawValue: self.value) {
                switch value {
                case .dry:
                    return (Double(1), "dry")
                case .sticky:
                    return (Double(2), "sticky")
                case .creamy:
                    return (Double(3), "creamy")
                case .watery:
                    return (Double(4), "watery")
                case .eggWhite:
                    return (Double(5), "eggWhite")
                }
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
