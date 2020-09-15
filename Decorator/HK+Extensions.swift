//
//  HK+Extensions.swift
//  HealthKitReporter
//
//  Created by Florian on 14.09.20.
//

import Foundation
import HealthKit

extension HKBiologicalSex {
    var string: String {
        switch self {
        case .notSet:
            return "na"
        case .female:
            return "Female"
        case .male:
            return "Male"
        case .other:
            return "Other"
        }
    }
}
extension HKBloodType {
    var string: String {
        switch self {
        case .notSet:
            return "na"
        case .aPositive:
            return "A+"
        case .aNegative:
            return "A-"
        case .bPositive:
            return "B+"
        case .bNegative:
            return "B-"
        case .abPositive:
            return "AB+"
        case .abNegative:
            return "AB-"
        case .oPositive:
            return "O+"
        case .oNegative:
            return "O-"
        }
    }
}
extension HKFitzpatrickSkinType {
    var string: String {
        switch self {
        case .notSet:
            return "na"
        case .I:
            return "I"
        case .II:
            return "II"
        case .III:
            return "III"
        case .IV:
            return "IV"
        case .V:
            return "V"
        case .VI:
            return "VI"
        }
    }
}
extension HKQuantityType {
    var statisticsOptions: HKStatisticsOptions {
        switch self.aggregationStyle {
        case .cumulative:
            return .cumulativeSum
        case .discreteArithmetic,
             .discreteTemporallyWeighted,
             .discreteEquivalentContinuousLevel:
            return .discreteAverage
        }
    }
}
extension HKStatistics {
    func parsed() throws -> (value: Double, unit: String) {
        if #available(iOS 13.0, *) {
            if self.quantityType == HKObjectType
                .quantityType(forIdentifier: .environmentalAudioExposure) {
                return try mostRecentQuantity(unit: HKUnit.decibelAWeightedSoundPressureLevel())
            }
            if self.quantityType == HKObjectType
                .quantityType(forIdentifier: .headphoneAudioExposure) {
                return try mostRecentQuantity(unit: HKUnit.decibelAWeightedSoundPressureLevel())
            }
        }
        switch self.quantityType {
        case HKObjectType.quantityType(forIdentifier: .bodyMassIndex):
            return try mostRecentQuantity(unit: HKUnit.count())
        case HKObjectType.quantityType(forIdentifier: .bodyFatPercentage):
            return try mostRecentQuantity(unit: HKUnit.percent())
        case HKObjectType.quantityType(forIdentifier: .bodyMass):
            return try mostRecentQuantity(unit: HKUnit.gramUnit(with: .kilo))
        case HKObjectType.quantityType(forIdentifier: .height):
            return try mostRecentQuantity(unit: HKUnit.meterUnit(with: HKMetricPrefix.centi))
        case HKObjectType.quantityType(forIdentifier: .waistCircumference):
            return try mostRecentQuantity(unit: HKUnit.meterUnit(with: HKMetricPrefix.centi))
        case HKObjectType.quantityType(forIdentifier: .vo2Max):
            return try mostRecentQuantity(
                unit: HKUnit
                    .literUnit(with: HKMetricPrefix.milli)
                    .unitDivided(by: HKUnit.gramUnit(with: HKMetricPrefix.kilo)
                        .unitMultiplied(by: HKUnit.minute())))
        case HKObjectType.quantityType(forIdentifier: .stepCount):
            return try sumQuantity(unit: HKUnit.count())
        case HKObjectType.quantityType(forIdentifier: .distanceCycling),
             HKObjectType.quantityType(forIdentifier: .distanceSwimming),
             HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning):
            return try sumQuantity(unit: HKUnit.meter())
        case HKObjectType.quantityType(forIdentifier: .heartRate):
            return try averageQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case HKObjectType.quantityType(forIdentifier: .restingHeartRate):
            return try averageQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case HKObjectType.quantityType(forIdentifier: .respiratoryRate):
            return try averageQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case HKObjectType.quantityType(forIdentifier: .basalEnergyBurned):
            return try sumQuantity(unit: HKUnit.largeCalorie())
        case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned):
            return try sumQuantity(unit: HKUnit.largeCalorie())
        case HKObjectType.quantityType(forIdentifier: .flightsClimbed):
            return try sumQuantity(unit: HKUnit.count())
        case HKObjectType.quantityType(forIdentifier: .basalBodyTemperature):
            return try averageQuantity( unit: HKUnit.kelvin())
        case HKObjectType.quantityType(forIdentifier: .bodyTemperature):
            return try averageQuantity(unit: HKUnit.kelvin())
        case HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed):
            return try sumQuantity(unit: HKUnit.largeCalorie())
        case HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryFiber):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietarySugar):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryFatTotal):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryFatSaturated):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryProtein):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminA):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryThiamin):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryRiboflavin):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryNiacin):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryPantothenicAcid):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminB6):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminB12):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminC):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminD):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminE):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminK):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryCalcium):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryIron):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryMagnesium),
             HKObjectType.quantityType(forIdentifier: .dietaryManganese) :
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryPhosphorus):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryPotassium):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietarySodium):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryZinc):
            return try sumQuantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryIodine):
            return try sumQuantity(unit: HKUnit.gram())
        default:
            throw HealthKitError.invalidType(
                "Invalid type: \(self.quantityType)"
            )
        }
    }

    private func mostRecentQuantity(unit: HKUnit) throws -> (value: Double, unit: String) {
        guard let value = self.mostRecentQuantity()?.doubleValue(for: unit) else {
            throw HealthKitError.invalidValue()
        }
        return (value, unit.unitString)
    }
    private func averageQuantity(unit: HKUnit) throws -> (value: Double, unit: String) {
        guard let value = self.averageQuantity()?.doubleValue(for: unit) else {
            throw HealthKitError.invalidValue()
        }
        return (value, unit.unitString)
    }
    private func sumQuantity(unit: HKUnit) throws -> (value: Double, unit: String) {
        guard let value = self.sumQuantity()?.doubleValue(for: unit) else {
            throw HealthKitError.invalidValue()
        }
        return (value, unit.unitString)
    }
}
