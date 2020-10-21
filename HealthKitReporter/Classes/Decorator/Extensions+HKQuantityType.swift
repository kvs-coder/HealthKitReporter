//
//  Extensions+HKQuantityType.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import Foundation
import HealthKit

extension HKQuantityType {
    func parsed() throws -> QuantityType {
        if #available(iOS 13.0, *) {
            if self == HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure) {
                return .environmentalAudioExposure
            }
            if self == HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure) {
                return .headphoneAudioExposure
            }
        }
        switch self {
        case HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN):
            return .heartRateVariabilitySDNN
        case HKObjectType.quantityType(forIdentifier: .bodyMassIndex):
            return .bodyMassIndex
        case HKObjectType.quantityType(forIdentifier: .bodyFatPercentage):
            return .bodyFatPercentage
        case HKObjectType.quantityType(forIdentifier: .heartRate):
            return .heartRate
        case HKObjectType.quantityType(forIdentifier: .respiratoryRate):
            return .respiratoryRate
        case HKObjectType.quantityType(forIdentifier: .oxygenSaturation):
            return .oxygenSaturation
        case HKObjectType.quantityType(forIdentifier: .bodyTemperature):
            return .bodyTemperature
        case HKObjectType.quantityType(forIdentifier: .basalBodyTemperature):
            return .basalBodyTemperature
        case HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic):
            return .bloodPressureSystolic
        case HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic):
            return .bloodPressureDiastolic
        case HKObjectType.quantityType(forIdentifier: .bloodGlucose):
            return .bloodGlucose
        case HKObjectType.quantityType(forIdentifier: .height):
            return .height
        case HKObjectType.quantityType(forIdentifier: .bodyMass):
            return .bodyMass
        case HKObjectType.quantityType(forIdentifier: .restingHeartRate):
            return .restingHeartRate
        case HKObjectType.quantityType(forIdentifier: .vo2Max):
            return .vo2Max
        case HKObjectType.quantityType(forIdentifier: .waistCircumference):
            return .waistCircumference
        case HKObjectType.quantityType(forIdentifier: .stepCount):
            return .stepCount
        case HKObjectType.quantityType(forIdentifier: .distanceSwimming):
            return .distanceSwimming
        case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning):
            return .distanceWalkingRunning
        case HKObjectType.quantityType(forIdentifier: .distanceCycling):
            return .distanceCycling
        case HKObjectType.quantityType(forIdentifier: .basalEnergyBurned):
            return .basalEnergyBurned
        case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned):
            return .activeEnergyBurned
        case HKObjectType.quantityType(forIdentifier: .flightsClimbed):
            return .flightsClimbed
        case HKObjectType.quantityType(forIdentifier: .appleExerciseTime):
            return .appleExerciseTime
        case HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed):
            return .dietaryEnergyConsumed
        case HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates):
            return .dietaryCarbohydrates
        case HKObjectType.quantityType(forIdentifier: .dietaryFiber):
            return .dietaryFiber
        case HKObjectType.quantityType(forIdentifier: .dietarySugar):
            return .dietarySugar
        case HKObjectType.quantityType(forIdentifier: .dietaryFatTotal):
            return .dietaryFatTotal
        case HKObjectType.quantityType(forIdentifier: .dietaryFatSaturated):
            return .dietaryFatSaturated
        case HKObjectType.quantityType(forIdentifier: .dietaryProtein):
            return .dietaryProtein
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminA):
            return .dietaryVitaminA
        case HKObjectType.quantityType(forIdentifier: .dietaryThiamin):
            return .dietaryThiamin
        case HKObjectType.quantityType(forIdentifier: .dietaryRiboflavin):
            return .dietaryRiboflavin
        case HKObjectType.quantityType(forIdentifier: .dietaryNiacin):
            return .dietaryNiacin
        case HKObjectType.quantityType(forIdentifier: .dietaryPantothenicAcid):
            return .dietaryPantothenicAcid
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminB6):
            return .dietaryVitaminB6
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminB12):
            return .dietaryVitaminB12
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminC):
            return .dietaryVitaminC
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminD):
            return .dietaryVitaminD
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminE):
            return .dietaryVitaminE
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminK):
            return .dietaryVitaminK
        case HKObjectType.quantityType(forIdentifier: .dietaryFolate):
            return .dietaryFolate
        case HKObjectType.quantityType(forIdentifier: .dietaryCalcium):
            return .dietaryCalcium
        case HKObjectType.quantityType(forIdentifier: .dietaryIron):
            return .dietaryIron
        case HKObjectType.quantityType(forIdentifier: .dietaryMagnesium):
            return .dietaryMagnesium
        case HKObjectType.quantityType(forIdentifier: .dietaryPhosphorus):
            return .dietaryPhosphorus
        case HKObjectType.quantityType(forIdentifier: .dietaryPotassium):
            return .dietaryPotassium
        case HKObjectType.quantityType(forIdentifier: .dietarySodium):
            return .dietarySodium
        case HKObjectType.quantityType(forIdentifier: .dietaryZinc):
            return .dietaryZinc
        case HKObjectType.quantityType(forIdentifier: .dietaryIodine):
            return .dietaryIodine
        case HKObjectType.quantityType(forIdentifier: .dietaryManganese):
            return .dietaryManganese
        default:
            throw HealthKitError.invalidType("Unknown HKObjectType")
        }
    }
    var statisticsOptions: HKStatisticsOptions {
        switch self.aggregationStyle {
        case .cumulative:
            return .cumulativeSum
        case .discreteArithmetic,
             .discreteTemporallyWeighted,
             .discreteEquivalentContinuousLevel:
            return .discreteAverage
        @unknown default:
            fatalError()
        }
    }
}
