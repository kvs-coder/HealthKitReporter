//
//  HealthKitType.swift
//  HealthKitReporter
//
//  Created by Florian on 14.09.20.
//

import Foundation
import HealthKit

public enum HealthKitType: RawRepresentable, CaseIterable {
    public typealias RawValue = HKObjectType?

    case unknown
    case dateOfBirth
    case bloodType
    case biologicalSex
    case heartbeatSeries
    case heartRateVariabilitySDNN
    case bodyMassIndex
    case bodyFatPercentage
    case heartRate
    case respiratoryRate
    case oxygenSaturation
    case bodyTemperature
    case basalBodyTemperature
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case bloodGlucose
    case height
    case bodyMass
    case restingHeartRate
    case vo2Max
    case waistCircumference
    case stepCount
    case distanceSwimming
    case distanceWalkingRunning
    case distanceCycling
    case basalEnergyBurned
    case activeEnergyBurned
    case flightsClimbed
    case appleExerciseTime
    case dietaryEnergyConsumed
    case dietaryCarbohydrates
    case dietaryFiber
    case dietarySugar
    case dietaryFatTotal
    case dietaryFatSaturated
    case dietaryProtein
    case dietaryVitaminA
    case dietaryThiamin
    case dietaryRiboflavin
    case dietaryNiacin
    case dietaryPantothenicAcid
    case dietaryVitaminB6
    case dietaryVitaminB12
    case dietaryVitaminC
    case dietaryVitaminD
    case dietaryVitaminE
    case dietaryVitaminK
    case dietaryFolate
    case dietaryCalcium
    case dietaryIron
    case dietaryMagnesium
    case dietaryPhosphorus
    case dietaryPotassium
    case dietarySodium
    case dietaryZinc
    case dietaryIodine
    case dietaryManganese
    case environmentalAudioExposure
    case headphoneAudioExposure
    case sleepAnalysis
    case appleStandHour
    case sexualActivity
    case intermenstrualBleeding
    case menstrualFlow
    case ovulationTestResult
    case cervicalMucusQuality
    case audioExposureEvent
    case activitySummary
    case workoutType
    case electrocardiogramType

    public var rawValue: HKObjectType? {
        switch self {
        case .unknown:
            return nil
        case .dateOfBirth:
            return HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
        case .bloodType:
            return HKObjectType.characteristicType(forIdentifier: .bloodType)
        case .biologicalSex:
            return HKObjectType.characteristicType(forIdentifier: .biologicalSex)
        case .heartbeatSeries:
            if #available(iOS 13.0, *) {
                return HKObjectType.seriesType(forIdentifier: HKDataTypeIdentifierHeartbeatSeries)
            } else {
                return nil
            }
        case .heartRateVariabilitySDNN:
            return HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        case .bodyMassIndex:
            return HKObjectType.quantityType(forIdentifier: .bodyMassIndex)
        case .bodyFatPercentage:
            return HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)
        case .heartRate:
            return HKObjectType.quantityType(forIdentifier: .heartRate)
        case .respiratoryRate:
            return HKObjectType.quantityType(forIdentifier: .respiratoryRate)
        case .oxygenSaturation:
            return HKObjectType.quantityType(forIdentifier: .oxygenSaturation)
        case .bodyTemperature:
            return HKObjectType.quantityType(forIdentifier: .bodyTemperature)
        case .basalBodyTemperature:
            return HKObjectType.quantityType(forIdentifier: .basalBodyTemperature)
        case .bloodPressureSystolic:
            return HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)
        case .bloodPressureDiastolic:
            return HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)
        case .bloodGlucose:
            return HKObjectType.quantityType(forIdentifier: .bloodGlucose)
        case .height:
            return HKObjectType.quantityType(forIdentifier: .height)
        case .bodyMass:
            return HKObjectType.quantityType(forIdentifier: .bodyMass)
        case .restingHeartRate:
            return HKObjectType.quantityType(forIdentifier: .restingHeartRate)
        case .vo2Max:
            return HKObjectType.quantityType(forIdentifier: .vo2Max)
        case .waistCircumference:
            return HKObjectType.quantityType(forIdentifier: .waistCircumference)
        case .stepCount:
            return HKObjectType.quantityType(forIdentifier: .stepCount)
        case .distanceSwimming:
            return HKObjectType.quantityType(forIdentifier: .distanceSwimming)
        case .distanceWalkingRunning:
            return HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
        case .distanceCycling:
            return HKObjectType.quantityType(forIdentifier: .distanceCycling)
        case .basalEnergyBurned:
            return HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)
        case .activeEnergyBurned:
            return HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        case .flightsClimbed:
            return HKObjectType.quantityType(forIdentifier: .flightsClimbed)
        case .appleExerciseTime:
            return HKObjectType.quantityType(forIdentifier: .appleExerciseTime)
        case .dietaryEnergyConsumed:
            return HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)
        case .dietaryCarbohydrates:
            return HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)
        case .dietaryFiber:
            return HKObjectType.quantityType(forIdentifier: .dietaryFiber)
        case .dietarySugar:
            return HKObjectType.quantityType(forIdentifier: .dietarySugar)
        case .dietaryFatTotal:
            return HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)
        case .dietaryFatSaturated:
            return HKObjectType.quantityType(forIdentifier: .dietaryFatSaturated)
        case .dietaryProtein:
            return HKObjectType.quantityType(forIdentifier: .dietaryProtein)
        case .dietaryVitaminA:
            return HKObjectType.quantityType(forIdentifier: .dietaryVitaminA)
        case .dietaryThiamin:
            return HKObjectType.quantityType(forIdentifier: .dietaryThiamin)
        case .dietaryRiboflavin:
            return HKObjectType.quantityType(forIdentifier: .dietaryRiboflavin)
        case .dietaryNiacin:
            return HKObjectType.quantityType(forIdentifier: .dietaryNiacin)
        case .dietaryPantothenicAcid:
            return HKObjectType.quantityType(forIdentifier: .dietaryPantothenicAcid)
        case .dietaryVitaminB6:
            return HKObjectType.quantityType(forIdentifier: .dietaryVitaminB6)
        case .dietaryVitaminB12:
            return HKObjectType.quantityType(forIdentifier: .dietaryVitaminB12)
        case .dietaryVitaminC:
            return HKObjectType.quantityType(forIdentifier: .dietaryVitaminC)
        case .dietaryVitaminD:
            return HKObjectType.quantityType(forIdentifier: .dietaryVitaminD)
        case .dietaryVitaminE:
            return HKObjectType.quantityType(forIdentifier: .dietaryVitaminE)
        case .dietaryVitaminK:
            return HKObjectType.quantityType(forIdentifier: .dietaryVitaminK)
        case .dietaryFolate:
            return HKObjectType.quantityType(forIdentifier: .dietaryFolate)
        case .dietaryCalcium:
            return HKObjectType.quantityType(forIdentifier: .dietaryCalcium)
        case .dietaryIron:
            return HKObjectType.quantityType(forIdentifier: .dietaryIron)
        case .dietaryMagnesium:
            return HKObjectType.quantityType(forIdentifier: .dietaryMagnesium)
        case .dietaryPhosphorus:
            return HKObjectType.quantityType(forIdentifier: .dietaryPhosphorus)
        case .dietaryPotassium:
            return HKObjectType.quantityType(forIdentifier: .dietaryPotassium)
        case .dietarySodium:
            return HKObjectType.quantityType(forIdentifier: .dietarySodium)
        case .dietaryZinc:
            return HKObjectType.quantityType(forIdentifier: .dietaryZinc)
        case .dietaryIodine:
            return HKObjectType.quantityType(forIdentifier: .dietaryIodine)
        case .dietaryManganese:
            return HKObjectType.quantityType(forIdentifier: .dietaryManganese)
        case .environmentalAudioExposure:
            if #available(iOS 13.0, *) {
                return HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)
            } else {
                return nil
            }
        case .headphoneAudioExposure:
            if #available(iOS 13.0, *) {
                return HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure)
            } else {
                return nil
            }
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
        case .activitySummary:
            return HKObjectType.activitySummaryType()
        case .workoutType:
            return HKWorkoutType.workoutType()
        case .electrocardiogramType:
            if #available(iOS 14.0, *) {
                return HKObjectType.electrocardiogramType()
            } else {
                return nil
            }
        }
    }

    public init?(rawValue: HKObjectType?) {
        return nil
    }
}
