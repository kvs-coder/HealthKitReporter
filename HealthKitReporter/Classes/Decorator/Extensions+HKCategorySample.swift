//
//  Extensions+HKCategoryself.swift
//  HealthKitReporter
//
//  Created by Florian on 15.09.20.
//

import Foundation
import HealthKit

extension HKCategorySample: HealthKitParsable {
    typealias Parseble = Category

    func parsed() throws -> Parseble {
        if #available(iOS 13.0, *) {
            if self.categoryType == HKObjectType.categoryType(forIdentifier: .audioExposureEvent) {
                if let value = HKCategoryValueAudioExposureEvent(rawValue: self.value) {
                    switch value {
                    case .loudEnvironment:
                        return category(1, "loudEnvironment")
                    @unknown default:
                        fatalError()
                    }
                }
            }
        }
        switch self.categoryType {
        case HKObjectType.categoryType(forIdentifier: .sleepAnalysis):
            if let sleepAnalisis = HKCategoryValueSleepAnalysis(rawValue: self.value) {
                switch sleepAnalisis {
                case .inBed:
                    return category(0, "inBed")
                case .asleep:
                    return category(1, "asleep")
                case .awake:
                    return category(2, "awake")
                @unknown default:
                    fatalError()
                }
            }
        case HKObjectType.categoryType(forIdentifier: .sexualActivity):
            if let metadata = self.metadata?[HKMetadataKeySexualActivityProtectionUsed] as? Int {
                switch metadata {
                case 1:
                    return category(1, "protectionUsed")
                case 2:
                    return category(2, "protectionNotUsed")
                default:
                    return category(3, "unspecified")
                }
            }
        case HKObjectType.categoryType(forIdentifier: .menstrualFlow):
            if let value = HKCategoryValueMenstrualFlow(rawValue: self.value) {
                switch value {
                case .unspecified:
                    return category(1, "unspecified")
                case .light:
                    return category(2, "light")
                case .medium:
                    return category(3, "medium")
                case .heavy:
                    return category(4, "heavy")
                case .none:
                    return category(5, "none")
                @unknown default:
                    fatalError()
                }
            }
        case HKObjectType.categoryType(forIdentifier: .ovulationTestResult):
            if let value = HKCategoryValueOvulationTestResult(rawValue: self.value) {
                switch value {
                case .negative:
                    return category(1, "negative")
                case .luteinizingHormoneSurge:
                    return category(2, "luteinizingHormoneSurge")
                case .indeterminate:
                    return category(3, "indeterminate")
                case .estrogenSurge:
                    return category(4, "estrogenSurge")
                @unknown default:
                    fatalError()
                }
            }
        case HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality):
            if let value = HKCategoryValueCervicalMucusQuality(rawValue: self.value) {
                switch value {
                case .dry:
                    return category(1, "dry")
                case .sticky:
                    return category(2, "sticky")
                case .creamy:
                    return category(3, "creamy")
                case .watery:
                    return category(4, "watery")
                case .eggWhite:
                    return category(5, "eggWhite")
                @unknown default:
                    fatalError()
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

    private func category(_ value: Int, _ unit: String) -> Category {
        return Category(
            categorySample: self,
            value: Double(value),
            unit: unit
        )
    }
}
