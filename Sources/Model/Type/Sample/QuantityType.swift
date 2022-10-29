//
//  QuantityType.swift
//  HealthKitReporter
//
//  Created by Victor on 05.10.20.
//

import HealthKit

/**
 All HealthKit qunatitiy types
 */
public enum QuantityType: Int, CaseIterable, SampleType {
    case bodyMassIndex
    case bodyFatPercentage
    case height
    case bodyMass
    case leanBodyMass
    case waistCircumference
    case stepCount
    case distanceWalkingRunning
    case distanceCycling
    case distanceWheelchair
    case basalEnergyBurned
    case activeEnergyBurned
    case flightsClimbed
    case nikeFuel
    case appleExerciseTime
    case pushCount
    case distanceSwimming
    case swimmingStrokeCount
    case vo2Max
    case distanceDownhillSnowSports
    case appleStandTime
    case walkingSpeed
    case walkingDoubleSupportPercentage
    case walkingAsymmetryPercentage
    case walkingStepLength
    case sixMinuteWalkTestDistance
    case stairAscentSpeed
    case stairDescentSpeed
    case heartRate
    case bodyTemperature
    case basalBodyTemperature
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case respiratoryRate
    case restingHeartRate
    case walkingHeartRateAverage
    case heartRateVariabilitySDNN
    case oxygenSaturation
    case peripheralPerfusionIndex
    case bloodGlucose
    case numberOfTimesFallen
    case electrodermalActivity
    case inhalerUsage
    case insulinDelivery
    case bloodAlcoholContent
    case forcedVitalCapacity
    case forcedExpiratoryVolume1
    case peakExpiratoryFlowRate
    case environmentalAudioExposure
    case headphoneAudioExposure
    case dietaryFatTotal
    case dietaryFatPolyunsaturated
    case dietaryFatMonounsaturated
    case dietaryFatSaturated
    case dietaryCholesterol
    case dietarySodium
    case dietaryCarbohydrates
    case dietaryFiber
    case dietarySugar
    case dietaryEnergyConsumed
    case dietaryProtein
    case dietaryVitaminA
    case dietaryVitaminB6
    case dietaryVitaminB12
    case dietaryVitaminC
    case dietaryVitaminD
    case dietaryVitaminE
    case dietaryVitaminK
    case dietaryCalcium
    case dietaryIron
    case dietaryThiamin
    case dietaryRiboflavin
    case dietaryNiacin
    case dietaryFolate
    case dietaryBiotin
    case dietaryPantothenicAcid
    case dietaryPhosphorus
    case dietaryIodine
    case dietaryMagnesium
    case dietaryZinc
    case dietarySelenium
    case dietaryCopper
    case dietaryManganese
    case dietaryChromium
    case dietaryMolybdenum
    case dietaryChloride
    case dietaryPotassium
    case dietaryCaffeine
    case dietaryWater
    case uvExposure
    case appleMoveTime
    case appleWalkingSteadiness
    case appleSleepingWristTemperature
    case runningStrideLength
    case runningVerticalOscillation
    case runningGroundContactTime
    case runningPower
    case runningSpeed
    case heartRateRecoveryOneMinute
    case numberOfAlcoholicBeverages
    case atrialFibrillationBurden
    case underwaterDepth
    case waterTemperature


    public var identifier: String? {
        return original?.identifier
    }

    public var original: HKObjectType? {
        switch self {
        case .heartRateVariabilitySDNN:
            if #available(iOS 11.0, *) {
                return HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
            }
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
            if #available(iOS 11.0, *) {
                return HKObjectType.quantityType(forIdentifier: .restingHeartRate)
            }
        case .vo2Max:
            if #available(iOS 11.0, *) {
                return HKObjectType.quantityType(forIdentifier: .vo2Max)
            }
        case .waistCircumference:
            if #available(iOS 11.0, *) {
                return HKObjectType.quantityType(forIdentifier: .waistCircumference)
            }
        case .stepCount:
            return HKObjectType.quantityType(forIdentifier: .stepCount)
        case .distanceSwimming:
            if #available(iOS 10.0, *) {
                return HKObjectType.quantityType(forIdentifier: .distanceSwimming)
            }
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
            if #available(iOS 9.3, *) {
                return HKObjectType.quantityType(forIdentifier: .appleExerciseTime)
            }
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
        case .dietaryWater:
            return HKObjectType.quantityType(forIdentifier: .dietaryWater)
        case .peakExpiratoryFlowRate:
            return HKObjectType.quantityType(forIdentifier: .peakExpiratoryFlowRate)
        case .leanBodyMass:
            return HKObjectType.quantityType(forIdentifier: .leanBodyMass)
        case .distanceWheelchair:
            if #available(iOS 10.0, *) {
                return HKObjectType.quantityType(forIdentifier: .distanceWheelchair)
            }
        case .nikeFuel:
            return HKObjectType.quantityType(forIdentifier: .nikeFuel)
        case .pushCount:
            if #available(iOS 10.0, *) {
                return HKObjectType.quantityType(forIdentifier: .pushCount)
            }
        case .swimmingStrokeCount:
            if #available(iOS 10.0, *) {
                return HKObjectType.quantityType(forIdentifier: .swimmingStrokeCount)
            }
        case .distanceDownhillSnowSports:
            if #available(iOS 11.2, *) {
                return HKObjectType.quantityType(forIdentifier: .distanceDownhillSnowSports)
            }
        case .walkingHeartRateAverage:
            if #available(iOS 11.0, *) {
                return HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)
            }
        case .peripheralPerfusionIndex:
            return HKObjectType.quantityType(forIdentifier: .peripheralPerfusionIndex)
        case .numberOfTimesFallen:
            return HKObjectType.quantityType(forIdentifier: .numberOfTimesFallen)
        case .electrodermalActivity:
            return HKObjectType.quantityType(forIdentifier: .electrodermalActivity)
        case .inhalerUsage:
            return HKObjectType.quantityType(forIdentifier: .inhalerUsage)
        case .insulinDelivery:
            if #available(iOS 11.0, *) {
                return HKObjectType.quantityType(forIdentifier: .insulinDelivery)
            }
        case .bloodAlcoholContent:
            return HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent)
        case .forcedVitalCapacity:
            return HKObjectType.quantityType(forIdentifier: .forcedVitalCapacity)
        case .forcedExpiratoryVolume1:
            return HKObjectType.quantityType(forIdentifier: .forcedExpiratoryVolume1)
        case .dietaryFatPolyunsaturated:
            return HKObjectType.quantityType(forIdentifier: .dietaryFatPolyunsaturated)
        case .dietaryFatMonounsaturated:
            return HKObjectType.quantityType(forIdentifier: .dietaryFatMonounsaturated)
        case .dietaryCholesterol:
            return HKObjectType.quantityType(forIdentifier: .dietaryCholesterol)
        case .dietaryBiotin:
            return HKObjectType.quantityType(forIdentifier: .dietaryBiotin)
        case .dietarySelenium:
            return HKObjectType.quantityType(forIdentifier: .dietarySelenium)
        case .dietaryCopper:
            return HKObjectType.quantityType(forIdentifier: .dietaryCopper)
        case .dietaryChromium:
            return HKObjectType.quantityType(forIdentifier: .dietaryChromium)
        case .dietaryMolybdenum:
            return HKObjectType.quantityType(forIdentifier: .dietaryMolybdenum)
        case .dietaryChloride:
            return HKObjectType.quantityType(forIdentifier: .dietaryChloride)
        case .dietaryCaffeine:
            return HKObjectType.quantityType(forIdentifier: .dietaryCaffeine)
        case .uvExposure:
            return HKObjectType.quantityType(forIdentifier: .uvExposure)
        case .environmentalAudioExposure:
            if #available(iOS 13.0, *) {
                return HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)
            }
        case .headphoneAudioExposure:
            if #available(iOS 13.0, *) {
                return HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure)
            }
        case .appleStandTime:
            if #available(iOS 13.0, *) {
                return HKObjectType.quantityType(forIdentifier: .appleStandTime)
            }
        case .walkingSpeed:
            if #available(iOS 14.0, *) {
                return HKObjectType.quantityType(forIdentifier: .walkingSpeed)
            }
        case .walkingDoubleSupportPercentage:
            if #available(iOS 14.0, *) {
                return HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)
            }
        case .walkingAsymmetryPercentage:
            if #available(iOS 14.0, *) {
                return HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage)
            }
        case .walkingStepLength:
            if #available(iOS 14.0, *) {
                return HKObjectType.quantityType(forIdentifier: .walkingStepLength)
            }
        case .sixMinuteWalkTestDistance:
            if #available(iOS 14.0, *) {
                return HKObjectType.quantityType(forIdentifier: .sixMinuteWalkTestDistance)
            }
        case .stairAscentSpeed:
            if #available(iOS 14.0, *) {
                return HKObjectType.quantityType(forIdentifier: .stairAscentSpeed)
            }
        case .stairDescentSpeed:
            if #available(iOS 14.0, *) {
                return HKObjectType.quantityType(forIdentifier: .stairDescentSpeed)
            }
        case .appleMoveTime:
            if #available(iOS 14.5, *) {
                return HKObjectType.quantityType(forIdentifier: .appleMoveTime)
            }
        case .appleWalkingSteadiness:
            if #available(iOS 15.0, *) {
                return HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)
            }
        case .appleSleepingWristTemperature:
            if #available(iOS 16.0, *) {
                return HKObjectType.quantityType(forIdentifier: .appleSleepingWristTemperature)
            }
        case .runningStrideLength:
            if #available(iOS 16.0, *) {
                return HKObjectType.quantityType(forIdentifier: .runningStrideLength)
            }
        case .runningVerticalOscillation:
            if #available(iOS 16.0, *) {
                return HKObjectType.quantityType(forIdentifier: .runningVerticalOscillation)
            }
        case .runningGroundContactTime:
            if #available(iOS 16.0, *) {
                return HKObjectType.quantityType(forIdentifier: .runningGroundContactTime)
            }
        case .runningPower:
            if #available(iOS 16.0, *) {
                return HKObjectType.quantityType(forIdentifier: .runningPower)
            }
        case .runningSpeed:
            if #available(iOS 16.0, *) {
                return HKObjectType.quantityType(forIdentifier: .runningSpeed)
            }
        case .heartRateRecoveryOneMinute:
            if #available(iOS 16.0, *) {
                return HKObjectType.quantityType(forIdentifier: .heartRateRecoveryOneMinute)
            }
        case .numberOfAlcoholicBeverages:
            if #available(iOS 15.0, *) {
                return HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)
            }
        case .atrialFibrillationBurden:
            if #available(iOS 16.0, *) {
                return HKObjectType.quantityType(forIdentifier: .atrialFibrillationBurden)
            }
        case .underwaterDepth:
            if #available(iOS 16.0, *) {
                return HKObjectType.quantityType(forIdentifier: .underwaterDepth)
            }
        case .waterTemperature:
            if #available(iOS 16.0, *) {
                return HKObjectType.quantityType(forIdentifier: .waterTemperature)
            }
        }
        return nil
    }
}
