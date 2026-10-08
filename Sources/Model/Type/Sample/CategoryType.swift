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
    case bleedingAfterPregnancy
    case bleedingDuringPregnancy
    case sleepApneaEvent
    case hypertensionEvent

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
            return HKObjectType.categoryType(forIdentifier: .environmentalAudioExposureEvent)
        case .mindfulSession:
            return HKObjectType.categoryType(forIdentifier: .mindfulSession)
        case .highHeartRateEvent:
            return HKObjectType.categoryType(forIdentifier: .highHeartRateEvent)
        case .lowHeartRateEvent:
            return HKObjectType.categoryType(forIdentifier: .lowHeartRateEvent)
        case .irregularHeartRhythmEvent:
            return HKObjectType.categoryType(forIdentifier: .irregularHeartRhythmEvent)
        case .toothbrushingEvent:
            return HKObjectType.categoryType(forIdentifier: .toothbrushingEvent)
        case .pregnancy:
            return HKObjectType.categoryType(forIdentifier: .pregnancy)
        case .lactation:
            return HKObjectType.categoryType(forIdentifier: .lactation)
        case .contraceptive:
            return HKObjectType.categoryType(forIdentifier: .contraceptive)
        case .environmentalAudioExposureEvent:
            return HKObjectType.categoryType(forIdentifier: .environmentalAudioExposureEvent)
        case .headphoneAudioExposureEvent:
            return HKObjectType.categoryType(forIdentifier: .headphoneAudioExposureEvent)
        case .handwashingEvent:
            return HKObjectType.categoryType(forIdentifier: .handwashingEvent)
        case .lowCardioFitnessEvent:
            return HKObjectType.categoryType(forIdentifier: .lowCardioFitnessEvent)
        case .abdominalCramps:
            return HKObjectType.categoryType(forIdentifier: .abdominalCramps)
        case .acne:
            return HKObjectType.categoryType(forIdentifier: .acne)
        case .appetiteChanges:
            return HKObjectType.categoryType(forIdentifier: .appetiteChanges)
        case .bladderIncontinence:
            return HKObjectType.categoryType(forIdentifier: .bladderIncontinence)
        case .bloating:
            return HKObjectType.categoryType(forIdentifier: .bloating)
        case .breastPain:
            return HKObjectType.categoryType(forIdentifier: .breastPain)
        case .chestTightnessOrPain:
            return HKObjectType.categoryType(forIdentifier: .chestTightnessOrPain)
        case .chills:
            return HKObjectType.categoryType(forIdentifier: .chills)
        case .constipation:
            return HKObjectType.categoryType(forIdentifier: .constipation)
        case .coughing:
            return HKObjectType.categoryType(forIdentifier: .coughing)
        case .diarrhea:
            return HKObjectType.categoryType(forIdentifier: .diarrhea)
        case .dizziness:
            return HKObjectType.categoryType(forIdentifier: .dizziness)
        case .drySkin:
            return HKObjectType.categoryType(forIdentifier: .drySkin)
        case .fainting:
            return HKObjectType.categoryType(forIdentifier: .fainting)
        case .fatigue:
            return HKObjectType.categoryType(forIdentifier: .fatigue)
        case .fever:
            return HKObjectType.categoryType(forIdentifier: .fever)
        case .generalizedBodyAche:
            return HKObjectType.categoryType(forIdentifier: .generalizedBodyAche)
        case .hairLoss:
            return HKObjectType.categoryType(forIdentifier: .hairLoss)
        case .headache:
            return HKObjectType.categoryType(forIdentifier: .headache)
        case .heartburn:
            return HKObjectType.categoryType(forIdentifier: .heartburn)
        case .hotFlashes:
            return HKObjectType.categoryType(forIdentifier: .hotFlashes)
        case .lossOfSmell:
            return HKObjectType.categoryType(forIdentifier: .lossOfSmell)
        case .lossOfTaste:
            return HKObjectType.categoryType(forIdentifier: .lossOfTaste)
        case .lowerBackPain:
            return HKObjectType.categoryType(forIdentifier: .lowerBackPain)
        case .memoryLapse:
            return HKObjectType.categoryType(forIdentifier: .memoryLapse)
        case .moodChanges:
            return HKObjectType.categoryType(forIdentifier: .moodChanges)
        case .nausea:
            return HKObjectType.categoryType(forIdentifier: .nausea)
        case .nightSweats:
            return HKObjectType.categoryType(forIdentifier: .nightSweats)
        case .pelvicPain:
            return HKObjectType.categoryType(forIdentifier: .pelvicPain)
        case .rapidPoundingOrFlutteringHeartbeat:
            return HKObjectType.categoryType(forIdentifier: .rapidPoundingOrFlutteringHeartbeat)
        case .runnyNose:
            return HKObjectType.categoryType(forIdentifier: .runnyNose)
        case .shortnessOfBreath:
            return HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)
        case .sinusCongestion:
            return HKObjectType.categoryType(forIdentifier: .sinusCongestion)
        case .skippedHeartbeat:
            return HKObjectType.categoryType(forIdentifier: .skippedHeartbeat)
        case .sleepChanges:
            return HKObjectType.categoryType(forIdentifier: .sleepChanges)
        case .soreThroat:
            return HKObjectType.categoryType(forIdentifier: .soreThroat)
        case .vaginalDryness:
            return HKObjectType.categoryType(forIdentifier: .vaginalDryness)
        case .vomiting:
            return HKObjectType.categoryType(forIdentifier: .vomiting)
        case .wheezing:
            return HKObjectType.categoryType(forIdentifier: .wheezing)
        case .pregnancyTestResult:
            return HKObjectType.categoryType(forIdentifier: .pregnancyTestResult)
        case .progesteroneTestResult:
            return HKObjectType.categoryType(forIdentifier: .progesteroneTestResult)
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
            return HKObjectType.categoryType(forIdentifier: .appleWalkingSteadinessEvent)
        case .bleedingAfterPregnancy:
            if #available(iOS 18.0, *) {
                return HKObjectType.categoryType(forIdentifier: .bleedingAfterPregnancy)
            }
        case .bleedingDuringPregnancy:
            if #available(iOS 18.0, *) {
                return HKObjectType.categoryType(forIdentifier: .bleedingDuringPregnancy)
            }
        case .sleepApneaEvent:
            if #available(iOS 18.0, *) {
                return HKObjectType.categoryType(forIdentifier: .sleepApneaEvent)
            }
        case .hypertensionEvent:
            if #available(iOS 26.2, *) {
                return HKObjectType.categoryType(forIdentifier: .hypertensionEvent)
            }
        }
        return nil
    }
}
