//
//  HKType.swift
//  HealthKitReporter
//
//  Created by Florian on 14.09.20.
//

import Foundation
import HealthKit

@objc(HKType) public final class HKType: NSObject {
    //Characteristic
    @objc public static let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
    @objc public static let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType)!
    @objc public static let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
    //Series
    @available(iOS 13.0, *)
    @objc public static let heartbeatSeries = HKObjectType
        .seriesType(forIdentifier: HKDataTypeIdentifierHeartbeatSeries)!
    @objc public static let heartRateVariabilitySDNN = HKObjectType
        .quantityType(forIdentifier: .heartRateVariabilitySDNN)!
    //Discrete
    @objc public static let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!
    @objc public static let bodyFatPercentage = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!
    @objc public static let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)!
    @objc public static let respiratoryRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
    @objc public static let oxygenSaturation = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
    @objc public static let bodyTemperature = HKObjectType.quantityType(forIdentifier: .bodyTemperature)!
    @objc public static let basalBodyTemperature = HKObjectType
        .quantityType(forIdentifier: .basalBodyTemperature)!
    @objc public static let bloodPressureSystolic = HKObjectType
        .quantityType(forIdentifier: .bloodPressureSystolic)!
    @objc public static let bloodPressureDiastolic = HKObjectType
        .quantityType(forIdentifier: .bloodPressureDiastolic)!
    @objc public static let bloodGlucose = HKObjectType.quantityType(forIdentifier: .bloodGlucose)!
    @objc public static let height = HKObjectType.quantityType(forIdentifier: .height)!
    @objc public static let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)!
    @objc public static let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
    @objc public static let vo2Max = HKObjectType.quantityType(forIdentifier: .vo2Max)!
    @objc public static let waistCircumference = HKObjectType
        .quantityType(forIdentifier: .waistCircumference)!
    //Cumulative
    @objc public static let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)!
    @objc public static let distanceSwimming = HKObjectType.quantityType(forIdentifier: .distanceSwimming)!
    @objc public static let distanceWalkingRunning = HKObjectType
        .quantityType(forIdentifier: .distanceWalkingRunning)!
    @objc public static let distanceCycling = HKObjectType.quantityType(forIdentifier: .distanceCycling)!
    @objc public static let basalEnergyBurned = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
    @objc public static let activeEnergyBurned = HKObjectType
        .quantityType(forIdentifier: .activeEnergyBurned)!
    @objc public static let flightsClimbed = HKObjectType.quantityType(forIdentifier: .flightsClimbed)!
    @objc public static let appleExerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
    @objc public static let dietaryEnergyConsumed = HKObjectType
        .quantityType(forIdentifier: .dietaryEnergyConsumed)!
    @objc public static let dietaryCarbohydrates = HKObjectType
        .quantityType(forIdentifier: .dietaryCarbohydrates)!
    @objc public static let dietaryFiber = HKObjectType.quantityType(forIdentifier: .dietaryFiber)!
    @objc public static let dietarySugar = HKObjectType.quantityType(forIdentifier: .dietarySugar)!
    @objc public static let dietaryFatTotal = HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!
    @objc public static let dietaryFatSaturated = HKObjectType
        .quantityType(forIdentifier: .dietaryFatSaturated)!
    @objc public static let dietaryProtein = HKObjectType.quantityType(forIdentifier: .dietaryProtein)!
    @objc public static let dietaryVitaminA = HKObjectType.quantityType(forIdentifier: .dietaryVitaminA)!
    @objc public static let dietaryThiamin = HKObjectType.quantityType(forIdentifier: .dietaryThiamin)!
    @objc public static let dietaryRiboflavin = HKObjectType.quantityType(forIdentifier: .dietaryRiboflavin)!
    @objc public static let dietaryNiacin = HKObjectType.quantityType(forIdentifier: .dietaryNiacin)!
    @objc public static let dietaryPantothenicAcid = HKObjectType
        .quantityType(forIdentifier: .dietaryPantothenicAcid)!
    @objc public static let dietaryVitaminB6 = HKObjectType.quantityType(forIdentifier: .dietaryVitaminB6)!
    @objc public static let dietaryVitaminB12 = HKObjectType.quantityType(forIdentifier: .dietaryVitaminB12)!
    @objc public static let dietaryVitaminC = HKObjectType.quantityType(forIdentifier: .dietaryVitaminC)!
    @objc public static let dietaryVitaminD = HKObjectType.quantityType(forIdentifier: .dietaryVitaminD)!
    @objc public static let dietaryVitaminE = HKObjectType.quantityType(forIdentifier: .dietaryVitaminE)!
    @objc public static let dietaryVitaminK = HKObjectType.quantityType(forIdentifier: .dietaryVitaminK)!
    @objc public static let dietaryFolate = HKObjectType.quantityType(forIdentifier: .dietaryFolate)!
    @objc public static let dietaryCalcium = HKObjectType.quantityType(forIdentifier: .dietaryCalcium)!
    @objc public static let dietaryIron = HKObjectType.quantityType(forIdentifier: .dietaryIron)!
    @objc public static let dietaryMagnesium = HKObjectType.quantityType(forIdentifier: .dietaryMagnesium)!
    @objc public static let dietaryPhosphorus = HKObjectType.quantityType(forIdentifier: .dietaryPhosphorus)!
    @objc public static let dietaryPotassium = HKObjectType.quantityType(forIdentifier: .dietaryPotassium)!
    @objc public static let dietarySodium = HKObjectType.quantityType(forIdentifier: .dietarySodium)!
    @objc public static let dietaryZinc = HKObjectType.quantityType(forIdentifier: .dietaryZinc)!
    @objc public static let dietaryIodine = HKObjectType.quantityType(forIdentifier: .dietaryIodine)!
    @objc public static let dietaryManganese = HKObjectType.quantityType(forIdentifier: .dietaryManganese)!
    @available(iOS 13.0, *)
    @objc public static let environmentalAudioExposure = HKObjectType
        .quantityType(forIdentifier: .environmentalAudioExposure)!
    @available(iOS 13.0, *)
    @objc public static let headphoneAudioExposure = HKObjectType
        .quantityType(forIdentifier: .headphoneAudioExposure)!
    @objc public static let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    @objc public static let appleStandHour = HKObjectType.categoryType(forIdentifier: .appleStandHour)!
    @objc public static let sexualActivity = HKObjectType.categoryType(forIdentifier: .sexualActivity)!
    @objc public static let intermenstrualBleeding = HKObjectType
        .categoryType(forIdentifier: .intermenstrualBleeding)!
    @objc public static let menstrualFlow = HKObjectType.categoryType(forIdentifier: .menstrualFlow)!
    @objc public static let ovulationTestResult = HKObjectType
        .categoryType(forIdentifier: .ovulationTestResult)!
    @objc public static let cervicalMucusQuality = HKObjectType
        .categoryType(forIdentifier: .cervicalMucusQuality)!
    @available(iOS 13.0, *)
    @objc public static let audioExposureEvent = HKObjectType
        .categoryType(forIdentifier: .audioExposureEvent)!
    @objc public static let activitySummary = HKObjectType.activitySummaryType()
    @objc public static let workoutType = HKWorkoutType.workoutType()

    @objc public static var allTypes: Set<HKObjectType> {
        var set: Set<HKObjectType> = [dateOfBirth,
                                      bloodType,
                                      biologicalSex,
                                      heartRateVariabilitySDNN ,
                                      bodyMassIndex,
                                      bodyFatPercentage,
                                      heartRate,
                                      respiratoryRate,
                                      oxygenSaturation,
                                      bodyTemperature,
                                      basalBodyTemperature,
                                      bloodPressureSystolic,
                                      bloodPressureDiastolic,
                                      bloodGlucose ,
                                      height,
                                      bodyMass,
                                      restingHeartRate,
                                      vo2Max,
                                      waistCircumference,
                                      stepCount,
                                      distanceSwimming,
                                      distanceWalkingRunning,
                                      distanceCycling,
                                      basalEnergyBurned,
                                      activeEnergyBurned,
                                      flightsClimbed,
                                      appleExerciseTime,
                                      dietaryEnergyConsumed,
                                      dietaryCarbohydrates,
                                      dietaryFiber,
                                      dietarySugar,
                                      dietaryFatTotal,
                                      dietaryFatSaturated,
                                      dietaryProtein,
                                      dietaryVitaminA,
                                      dietaryThiamin,
                                      dietaryRiboflavin,
                                      dietaryNiacin,
                                      dietaryPantothenicAcid,
                                      dietaryVitaminB6,
                                      dietaryVitaminB12,
                                      dietaryVitaminC,
                                      dietaryVitaminD,
                                      dietaryVitaminE,
                                      dietaryVitaminK,
                                      dietaryFolate,
                                      dietaryCalcium,
                                      dietaryIron,
                                      dietaryMagnesium,
                                      dietaryPhosphorus,
                                      dietaryPotassium,
                                      dietarySodium,
                                      dietaryZinc,
                                      dietaryIodine,
                                      dietaryManganese,
                                      sleepAnalysis,
                                      appleStandHour,
                                      sexualActivity,
                                      intermenstrualBleeding,
                                      menstrualFlow,
                                      ovulationTestResult,
                                      cervicalMucusQuality,
                                      activitySummary,
                                      workoutType]
        if #available(iOS 13.0, *) {
            set.insert(heartbeatSeries)
            set.insert(environmentalAudioExposure)
            set.insert(headphoneAudioExposure)
            set.insert(audioExposureEvent)
        }
        return set
    }
}
