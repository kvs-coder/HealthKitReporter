//
//  CategoryType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

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
    case pregnancyTestResult
    case progesteroneTestResult
    case persistentIntermenstrualBleeding
    case prolongedMenstrualPeriods
    case irregularMenstrualCycles
    case infrequentMenstrualCycles
    case appleWalkingSteadinessEvent

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
            }
        case .mindfulSession:
            if #available(iOS 10.0, *) {
                return HKObjectType.categoryType(forIdentifier: .mindfulSession)
            }
        case .highHeartRateEvent:
            if #available(iOS 12.2, *) {
                return HKObjectType.categoryType(forIdentifier: .highHeartRateEvent)
            }
        case .lowHeartRateEvent:
            if #available(iOS 12.2, *) {
                return HKObjectType.categoryType(forIdentifier: .lowHeartRateEvent)
            }
        case .irregularHeartRhythmEvent:
            if #available(iOS 12.2, *) {
                return HKObjectType.categoryType(forIdentifier: .irregularHeartRhythmEvent)
            }
        case .toothbrushingEvent:
            if #available(iOS 13.0, *) {
                return HKObjectType.categoryType(forIdentifier: .toothbrushingEvent)
            }
        case .pregnancy:
            if #available(iOS 14.3, *) {
                return HKObjectType.categoryType(forIdentifier: .pregnancy)
            }
        case .lactation:
            if #available(iOS 14.3, *) {
                return HKObjectType.categoryType(forIdentifier: .lactation)
            }
        case .contraceptive:
            if #available(iOS 14.3, *) {
                return HKObjectType.categoryType(forIdentifier: .contraceptive)
            }
        case .environmentalAudioExposureEvent:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .environmentalAudioExposureEvent)
            }
        case .headphoneAudioExposureEvent:
            if #available(iOS 14.2, *) {
                return HKObjectType.categoryType(forIdentifier: .headphoneAudioExposureEvent)
            }
        case .handwashingEvent:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .handwashingEvent)
            }
        case .lowCardioFitnessEvent:
            if #available(iOS 14.3, *) {
                return HKObjectType.categoryType(forIdentifier: .lowCardioFitnessEvent)
            }
        case .abdominalCramps:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .abdominalCramps)
            }
        case .acne:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .acne)
            }
        case .appetiteChanges:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .appetiteChanges)
            }
        case .bladderIncontinence:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .bladderIncontinence)
            }
        case .bloating:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .bloating)
            }
        case .breastPain:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .breastPain)
            }
        case .chestTightnessOrPain:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .chestTightnessOrPain)
            }
        case .chills:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .chills)
            }
        case .constipation:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .constipation)
            }
        case .coughing:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .coughing)
            }
        case .diarrhea:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .diarrhea)
            }
        case .dizziness:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .dizziness)
            }
        case .drySkin:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .drySkin)
            }
        case .fainting:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .fainting)
            }
        case .fatigue:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .fatigue)
            }
        case .fever:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .fever)
            }
        case .generalizedBodyAche:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .generalizedBodyAche)
            }
        case .hairLoss:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .hairLoss)
            }
        case .headache:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .headache)
            }
        case .heartburn:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .heartburn)
            }
        case .hotFlashes:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .hotFlashes)
            }
        case .lossOfSmell:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .lossOfSmell)
            }
        case .lossOfTaste:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .lossOfTaste)
            }
        case .lowerBackPain:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .lowerBackPain)
            }
        case .memoryLapse:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .memoryLapse)
            }
        case .moodChanges:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .moodChanges)
            }
        case .nausea:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .nausea)
            }
        case .nightSweats:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .nightSweats)
            }
        case .pelvicPain:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .pelvicPain)
            }
        case .rapidPoundingOrFlutteringHeartbeat:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .rapidPoundingOrFlutteringHeartbeat)
            }
        case .runnyNose:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .runnyNose)
            }
        case .shortnessOfBreath:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)
            }
        case .sinusCongestion:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .sinusCongestion)
            }
        case .skippedHeartbeat:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .skippedHeartbeat)
            }
        case .sleepChanges:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .sleepChanges)
            }
        case .soreThroat:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .soreThroat)
            }
        case .vaginalDryness:
            if #available(iOS 14.0, *) {
                return HKObjectType.categoryType(forIdentifier: .vaginalDryness)
            }
        case .vomiting:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .vomiting)
            }
        case .wheezing:
            if #available(iOS 13.6, *) {
                return HKObjectType.categoryType(forIdentifier: .wheezing)
            }
        case .pregnancyTestResult:
            if #available(iOS 15.0, *) {
                return HKObjectType.categoryType(forIdentifier: .pregnancyTestResult)
            }
        case .progesteroneTestResult:
            if #available(iOS 15.0, *) {
                return HKObjectType.categoryType(forIdentifier: .progesteroneTestResult)
            }
        case .persistentIntermenstrualBleeding:
            if #available(iOS 16.0, *) {
                return HKObjectType.categoryType(forIdentifier: .persistentIntermenstrualBleeding)
            }
        case .prolongedMenstrualPeriods:
            if #available(iOS 16.0, *) {
                return HKObjectType.categoryType(forIdentifier: .prolongedMenstrualPeriods)
            }
        case .irregularMenstrualCycles:
            if #available(iOS 16.0, *) {
                return HKObjectType.categoryType(forIdentifier: .irregularMenstrualCycles)
            }
        case .infrequentMenstrualCycles:
            if #available(iOS 16.0, *) {
                return HKObjectType.categoryType(forIdentifier: .infrequentMenstrualCycles)
            }
        case .appleWalkingSteadinessEvent:
            if #available(iOS 15.0, *) {
                return HKObjectType.categoryType(forIdentifier: .appleWalkingSteadinessEvent)
            }
        }
        return nil
    }
}
