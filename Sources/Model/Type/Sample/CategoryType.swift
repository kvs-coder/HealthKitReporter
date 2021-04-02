//
//  CategoryType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import Foundation
import HealthKit

/**
 All HealthKit category types
 */
public enum CategoryType: Int, CaseIterable, SampleType {
    case sleepAnalysis
    case appleStandHour
    case cervicalMucusQuality
    case ovulationTestResult
    case menstrualFlow
    case intermenstrualBleeding
    case sexualActivity
    case mindfulSession
    case highHeartRateEvent
    case lowHeartRateEvent
    case irregularHeartRhythmEvent
    case toothbrushingEvent
    case pregnancy
    case lactation
    case contraceptive
    case audioExposureEvent
    case environmentalAudioExposureEvent
    case headphoneAudioExposureEvent
    case handwashingEvent
    case lowCardioFitnessEvent
    case abdominalCramps
    case acne
    case appetiteChanges
    case bladderIncontinence
    case bloating
    case breastPain
    case chestTightnessOrPain
    case chills
    case constipation
    case coughing
    case diarrhea
    case dizziness
    case drySkin
    case fainting
    case fatigue
    case fever
    case generalizedBodyAche
    case hairLoss
    case headache
    case heartburn
    case hotFlashes
    case lossOfSmell
    case lossOfTaste
    case lowerBackPain
    case memoryLapse
    case moodChanges
    case nausea
    case nightSweats
    case pelvicPain
    case rapidPoundingOrFlutteringHeartbeat
    case runnyNose
    case shortnessOfBreath
    case sinusCongestion
    case skippedHeartbeat
    case sleepChanges
    case soreThroat
    case vaginalDryness
    case vomiting
    case wheezing

    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .sleepAnalysis:
            return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case .appleStandHour:
            return HKObjectType.categoryType(forIdentifier: .appleStandHour)
        case .sexualActivity:
            return HKObjectType.categoryType(forIdentifier: .sexualActivity)
        case .intermenstrualBleeding:
            return HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding)
        case .menstrualFlow:
            return HKObjectType.categoryType(forIdentifier: .menstrualFlow)
        case .ovulationTestResult:
            return HKObjectType.categoryType(forIdentifier: .ovulationTestResult)
        case .cervicalMucusQuality:
            return HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality)
        case .audioExposureEvent:
            if #available(iOS 13.0, *) {
                return HKObjectType.categoryType(forIdentifier: .audioExposureEvent)
            } else {
                return nil
            }
        case .mindfulSession:
            if #available(iOS 10.0, *) {
                return HKObjectType.categoryType(forIdentifier: .mindfulSession)
            } else {
                return nil
            }
        case .highHeartRateEvent:
            if #available(iOS 12.2, *) {
                return HKObjectType.categoryType(forIdentifier: .highHeartRateEvent)
            } else {
                return nil
            }
        case .lowHeartRateEvent:
            if #available(iOS 12.2, *) {
                return HKObjectType.categoryType(forIdentifier: .lowHeartRateEvent)
            } else {
                return nil
            }
        case .irregularHeartRhythmEvent:
            if #available(iOS 12.2, *) {
                return HKObjectType.categoryType(forIdentifier: .irregularHeartRhythmEvent)
            } else {
                return nil
            }
        case .toothbrushingEvent:
            if #available(iOS 13.0, *) {
                return HKObjectType.categoryType(forIdentifier: .toothbrushingEvent)
            } else {
                return nil
            }
        case .pregnancy:
            if #available(iOS 14.3, *) {
                return HKObjectType.categoryType(forIdentifier: .pregnancy)
            } else {
                return nil
            }
        case .lactation:
            if #available(iOS 14.3, *) {
                return HKObjectType.categoryType(forIdentifier: .lactation)
            } else {
                return nil
            }
        case .contraceptive:
            if #available(iOS 14.3, *) {
                return HKObjectType.categoryType(forIdentifier: .contraceptive)
            } else {
                return nil
            }
        case .environmentalAudioExposureEvent:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .environmentalAudioExposureEvent)
            } else {
                return nil
            }
        case .headphoneAudioExposureEvent:
            if #available(iOS 14.2, *) {
                return HKObjectType.categoryType(forIdentifier: .headphoneAudioExposureEvent)
            } else {
                return nil
            }
        case .handwashingEvent:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .handwashingEvent)
            } else {
                return nil
            }
        case .lowCardioFitnessEvent:
            if #available(iOS 14.3, *) {
                return HKObjectType.categoryType(forIdentifier: .lowCardioFitnessEvent)
            } else {
                return nil
            }
        case .abdominalCramps:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .abdominalCramps)
            } else {
                return nil
            }
        case .acne:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .acne)
            } else {
                return nil
            }
        case .appetiteChanges:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .appetiteChanges)
            } else {
                return nil
            }
        case .bladderIncontinence:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .bladderIncontinence)
            } else {
                return nil
            }
        case .bloating:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .bloating)
            } else {
                return nil
            }
        case .breastPain:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .breastPain)
            } else {
                return nil
            }
        case .chestTightnessOrPain:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .chestTightnessOrPain)
            } else {
                return nil
            }
        case .chills:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .chills)
            } else {
                return nil
            }
        case .constipation:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .constipation)
            } else {
                return nil
            }
        case .coughing:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .coughing)
            } else {
                return nil
            }
        case .diarrhea:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .diarrhea)
            } else {
                return nil
            }
        case .dizziness:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .dizziness)
            } else {
                return nil
            }
        case .drySkin:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .drySkin)
            } else {
                return nil
            }
        case .fainting:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .fainting)
            } else {
                return nil
            }
        case .fatigue:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .fatigue)
            } else {
                return nil
            }
        case .fever:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .fever)
            } else {
                return nil
            }
        case .generalizedBodyAche:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .generalizedBodyAche)
            } else {
                return nil
            }
        case .hairLoss:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .hairLoss)
            } else {
                return nil
            }
        case .headache:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .headache)
            } else {
                return nil
            }
        case .heartburn:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .heartburn)
            } else {
                return nil
            }
        case .hotFlashes:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .hotFlashes)
            } else {
                return nil
            }
        case .lossOfSmell:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .lossOfSmell)
            } else {
                return nil
            }
        case .lossOfTaste:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .lossOfTaste)
            } else {
                return nil
            }
        case .lowerBackPain:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .lowerBackPain)
            } else {
                return nil
            }
        case .memoryLapse:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .memoryLapse)
            } else {
                return nil
            }
        case .moodChanges:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .moodChanges)
            } else {
                return nil
            }
        case .nausea:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .nausea)
            } else {
                return nil
            }
        case .nightSweats:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .nightSweats)
            } else {
                return nil
            }
        case .pelvicPain:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .pelvicPain)
            } else {
                return nil
            }
        case .rapidPoundingOrFlutteringHeartbeat:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .rapidPoundingOrFlutteringHeartbeat)
            } else {
                return nil
            }
        case .runnyNose:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .runnyNose)
            } else {
                return nil
            }
        case .shortnessOfBreath:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)
            } else {
                return nil
            }
        case .sinusCongestion:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .sinusCongestion)
            } else {
                return nil
            }
        case .skippedHeartbeat:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .skippedHeartbeat)
            } else {
                return nil
            }
        case .sleepChanges:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .sleepChanges)
            } else {
                return nil
            }
        case .soreThroat:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .soreThroat)
            } else {
                return nil
            }
        case .vaginalDryness:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .vaginalDryness)
            } else {
                return nil
            }
        case .vomiting:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .vomiting)
            } else {
                return nil
            }
        case .wheezing:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .wheezing)
            } else {
                return nil
            }
        }
    }
}
