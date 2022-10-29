//
//  Extensions+HKCategorySample.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

extension HKCategorySample: Harmonizable {
    typealias Harmonized = Category.Harmonized
    
    func harmonize() throws -> Harmonized {
        var description = String()
        var detail = String()
        let type = try categoryType.parsed()
        switch type {
        case .audioExposureEvent:
            if #available(iOS 13.0, *) {
                if let value = HKCategoryValueAudioExposureEvent(rawValue: value) {
                    description = value.description
                    detail = value.detail
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .sleepAnalysis:
            if let value = HKCategoryValueSleepAnalysis(rawValue: value) {
                description = value.description
                detail = value.detail
            }
        case .intermenstrualBleeding,
             .mindfulSession,
             .highHeartRateEvent,
             .lowHeartRateEvent,
             .irregularHeartRhythmEvent,
             .toothbrushingEvent,
             .pregnancy,
             .lactation,
             .sexualActivity,
             .handwashingEvent,
             .persistentIntermenstrualBleeding,
             .prolongedMenstrualPeriods,
             .irregularMenstrualCycles,
             .infrequentMenstrualCycles:
            if let value = HKCategoryValue(rawValue: value) {
                description = value.description
                detail = value.detail
            }
        case .menstrualFlow:
            if let value = HKCategoryValueMenstrualFlow(rawValue: value) {
                description = value.description
                detail = value.detail
            }
        case .ovulationTestResult:
            if let value = HKCategoryValueOvulationTestResult(rawValue: value) {
                description = value.description
                detail = value.detail
            }
        case .cervicalMucusQuality:
            if let value = HKCategoryValueCervicalMucusQuality(rawValue: value) {
                description = value.description
                detail = value.detail
            }
        case .appleStandHour:
            if let value = HKCategoryValueAppleStandHour(rawValue: value) {
                description = value.description
                detail = value.detail
            }

        case .contraceptive:
            if #available(iOS 14.3, *) {
                if let value = HKCategoryValueContraceptive(rawValue: value) {
                    description = value.description
                    detail = value.detail
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .environmentalAudioExposureEvent:
            if #available(iOS 14.0, *) {
                if let value = HKCategoryValueEnvironmentalAudioExposureEvent(rawValue: value) {
                    description = value.description
                    detail = value.detail
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .headphoneAudioExposureEvent:
            if #available(iOS 14.2, *) {
                if let value = HKCategoryValueHeadphoneAudioExposureEvent(rawValue: value) {
                    description = value.description
                    detail = value.detail
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .lowCardioFitnessEvent:
            if #available(iOS 14.3, *) {
                if let value = HKCategoryValueLowCardioFitnessEvent(rawValue: value) {
                    description = value.description
                    detail = value.detail
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .appetiteChanges:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValueAppetiteChanges(rawValue: value) {
                    description = value.description
                    detail = value.detail
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .abdominalCramps,
             .acne,
             .bladderIncontinence,
             .bloating,
             .breastPain,
             .chestTightnessOrPain,
             .chills,
             .constipation,
             .coughing,
             .diarrhea,
             .dizziness,
             .drySkin,
             .fainting,
             .fatigue,
             .fever,
             .generalizedBodyAche,
             .hairLoss,
             .headache,
             .heartburn,
             .hotFlashes,
             .lossOfSmell,
             .lossOfTaste,
             .lowerBackPain,
             .memoryLapse,
             .moodChanges,
             .nausea,
             .nightSweats,
             .pelvicPain,
             .rapidPoundingOrFlutteringHeartbeat,
             .runnyNose,
             .shortnessOfBreath,
             .sinusCongestion,
             .skippedHeartbeat,
             .sleepChanges,
             .soreThroat,
             .vaginalDryness,
             .vomiting,
             .wheezing:
            if #available(iOS 13.6, *) {
                if let value = HKCategoryValuePresence(rawValue: value) {
                    description = value.description
                    detail = value.detail
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .pregnancyTestResult:
            if #available(iOS 15.0, *) {
                if let value = HKCategoryValuePregnancyTestResult(rawValue: value) {
                    description = value.description
                    detail = value.detail
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .progesteroneTestResult:
            if #available(iOS 15.0, *) {
                if let value = HKCategoryValueProgesteroneTestResult(rawValue: value) {
                    description = value.description
                    detail = value.detail
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .appleWalkingSteadinessEvent:
            if #available(iOS 15.0, *) {
                if let value = HKCategoryValueAppleWalkingSteadinessEvent(rawValue: value) {
                    description = value.description
                    detail = value.detail
                }
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        }
        return category(description: description, detail: detail)
    }
    
    private func category(description: String, detail: String) -> Harmonized {
        return Harmonized(
            value: value,
            description: description,
            detail: detail,
            metadata: metadata?.asMetadata
        )
    }
}
