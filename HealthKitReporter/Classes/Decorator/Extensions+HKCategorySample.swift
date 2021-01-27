//
//  Extensions+HKCategoryself.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import Foundation
import HealthKit

extension HKCategorySample: Harmonizable {
    typealias Harmonized = Category.Harmonized
    
    func harmonize() throws -> Harmonized {
        let type = try categoryType.parsed()
        switch type {
        case .audioExposureEvent:
            if #available(iOS 13.0, *) {
                if let value = HKCategoryValueAudioExposureEvent(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .sleepAnalysis:
            if let value = HKCategoryValueSleepAnalysis(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .sexualActivity:
            if let value = HKCategoryValue(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .menstrualFlow:
            if let value = HKCategoryValueMenstrualFlow(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .ovulationTestResult:
            if let value = HKCategoryValueOvulationTestResult(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .cervicalMucusQuality:
            if let value = HKCategoryValueCervicalMucusQuality(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .appleStandHour:
            if let value = HKCategoryValueAppleStandHour(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .intermenstrualBleeding:
            if let value = HKCategoryValue(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .mindfulSession:
            if let value = HKCategoryValue(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .highHeartRateEvent:
            if let value = HKCategoryValue(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .lowHeartRateEvent:
            if let value = HKCategoryValue(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .irregularHeartRhythmEvent:
            if let value = HKCategoryValue(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .toothbrushingEvent:
            if let value = HKCategoryValue(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .pregnancy:
            if let value = HKCategoryValue(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .lactation:
            if let value = HKCategoryValue(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .contraceptive:
            if #available(iOS 14.3, *) {
                if let value = HKCategoryValueContraceptive(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .environmentalAudioExposureEvent:
            if #available(iOS 14.0, *) {
                if let value = HKCategoryValueEnvironmentalAudioExposureEvent(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .headphoneAudioExposureEvent:
            if #available(iOS 14.2, *) {
                if let value = HKCategoryValueHeadphoneAudioExposureEvent(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .handwashingEvent:
            if let value = HKCategoryValue(rawValue: value) {
                return category(description: String(describing: value))
            }
        case .lowCardioFitnessEvent:
            if #available(iOS 14.3, *) {
                if let value = HKCategoryValueLowCardioFitnessEvent(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .abdominalCramps:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .acne:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .appetiteChanges:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueAppetiteChanges(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .bladderIncontinence:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .bloating:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .breastPain:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .chestTightnessOrPain:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .chills:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .constipation:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .coughing:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .diarrhea:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .dizziness:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .drySkin:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .fainting:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .fatigue:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .fever:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .generalizedBodyAche:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .hairLoss:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .headache:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .heartburn:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .hotFlashes:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .lossOfSmell:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .lossOfTaste:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .lowerBackPain:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .memoryLapse:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .moodChanges:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValuePresence(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .nausea:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .nightSweats:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .pelvicPain:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .rapidPoundingOrFlutteringHeartbeat:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .runnyNose:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .shortnessOfBreath:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .sinusCongestion:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .skippedHeartbeat:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .sleepChanges:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValuePresence(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .soreThroat:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .vaginalDryness:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .vomiting:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .wheezing:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueSeverity(rawValue: value) {
                    return category(description: String(describing: value))
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        }
        throw HealthKitError.invalidValue(
            "Invalid value for: \(self.categoryType). Can not be recognized"
        )
    }

    private func category(description: String) -> Harmonized {
        return Harmonized(
            value: value,
            description: description,
            metadata: metadata?.compactMapValues { String(describing: $0 )}
        )
    }
}
