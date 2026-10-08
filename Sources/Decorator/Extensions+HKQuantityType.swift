//
//  Extensions+HKQuantityType.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

extension HKQuantityType {
    func parsed() throws -> QuantityType {
        guard let type = identifier.objectType as? QuantityType else {
            throw HealthKitError.invalidType("Unknown HKQuantityType with identifier: \(identifier)")
        }
        return type
    }
    /// The SI unit payloads harmonize this type to; the single source for samples and statistics
    var siUnit: HKUnit {
        get throws {
            let type = try parsed()
            switch type {
            case .stepCount,
                 .flightsClimbed,
                 .bodyMassIndex,
                 .nikeFuel,
                 .pushCount,
                 .swimmingStrokeCount,
                 .numberOfTimesFallen,
                 .inhalerUsage,
                 .uvExposure,
                 .numberOfAlcoholicBeverages,
                 .appleSleepingBreathingDisturbances:
                return HKUnit.count()
            case .distanceCycling,
                 .distanceSwimming,
                 .distanceWalkingRunning,
                 .distanceWheelchair,
                 .distanceDownhillSnowSports,
                 .height,
                 .waistCircumference,
                 .walkingStepLength,
                 .sixMinuteWalkTestDistance,
                 .runningStrideLength,
                 .runningVerticalOscillation,
                 .underwaterDepth,
                 .distanceCrossCountrySkiing,
                 .distancePaddleSports,
                 .distanceRowing,
                 .distanceSkatingSports:
                return HKUnit.meter()
            case .heartRate,
                 .respiratoryRate,
                 .restingHeartRate,
                 .walkingHeartRateAverage,
                 .heartRateRecoveryOneMinute,
                 .cyclingCadence:
                return HKUnit.count().unitDivided(by: HKUnit.minute())
            case .basalEnergyBurned,
                 .activeEnergyBurned,
                 .dietaryEnergyConsumed:
                return HKUnit.largeCalorie()
            case .basalBodyTemperature,
                 .bodyTemperature,
                 .appleSleepingWristTemperature,
                 .waterTemperature:
                return HKUnit.kelvin()
            case .oxygenSaturation,
                 .bodyFatPercentage,
                 .walkingDoubleSupportPercentage,
                 .walkingAsymmetryPercentage,
                 .peripheralPerfusionIndex,
                 .bloodAlcoholContent,
                 .appleWalkingSteadiness,
                 .atrialFibrillationBurden:
                return HKUnit.percent()
            case .bloodPressureSystolic,
                 .bloodPressureDiastolic:
                return HKUnit.millimeterOfMercury()
            case .bloodGlucose:
                return HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.liter())
            case .dietaryCarbohydrates,
                 .dietaryFiber,
                 .dietarySugar,
                 .dietaryFatTotal,
                 .dietaryFatSaturated,
                 .dietaryProtein,
                 .dietaryVitaminA,
                 .dietaryThiamin,
                 .dietaryRiboflavin,
                 .dietaryNiacin,
                 .dietaryPantothenicAcid,
                 .dietaryVitaminB6,
                 .dietaryVitaminB12,
                 .dietaryVitaminC,
                 .dietaryVitaminD,
                 .dietaryVitaminE,
                 .dietaryVitaminK,
                 .dietaryCalcium,
                 .dietaryIron,
                 .dietaryMagnesium,
                 .dietaryManganese,
                 .dietaryPhosphorus,
                 .dietaryPotassium,
                 .dietarySodium,
                 .dietaryZinc,
                 .dietaryIodine,
                 .dietaryFatPolyunsaturated,
                 .dietaryFatMonounsaturated,
                 .dietaryCholesterol,
                 .dietaryFolate,
                 .dietaryBiotin,
                 .dietarySelenium,
                 .dietaryCopper,
                 .dietaryChromium,
                 .dietaryMolybdenum,
                 .dietaryChloride,
                 .dietaryCaffeine:
                return HKUnit.gram()
            case .peakExpiratoryFlowRate:
                return HKUnit.liter().unitDivided(by: HKUnit.minute())
            case .bodyMass,
                 .leanBodyMass:
                return HKUnit.gramUnit(with: .kilo)
            case .appleExerciseTime,
                 .appleStandTime,
                 .appleMoveTime,
                 .runningGroundContactTime,
                 .timeInDaylight:
                return HKUnit.second()
            case .vo2Max:
                return HKUnit.literUnit(with: .milli).unitDivided(
                    by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: HKUnit.minute())
                )
            case .walkingSpeed,
                 .stairAscentSpeed,
                 .stairDescentSpeed,
                 .runningSpeed,
                 .cyclingSpeed,
                 .crossCountrySkiingSpeed,
                 .paddleSportsSpeed,
                 .rowingSpeed:
                return HKUnit.meter().unitDivided(by: HKUnit.second())
            case .heartRateVariabilitySDNN:
                return HKUnit.secondUnit(with: .milli)
            case .electrodermalActivity:
                return HKUnit.siemen()
            case .insulinDelivery:
                return HKUnit.internationalUnit()
            case .forcedVitalCapacity,
                 .forcedExpiratoryVolume1,
                 .dietaryWater:
                return HKUnit.literUnit(with: .milli)
            case .environmentalAudioExposure,
                 .headphoneAudioExposure,
                 .environmentalSoundReduction:
                return HKUnit.decibelAWeightedSoundPressureLevel()
            case .runningPower,
                 .cyclingPower,
                 .cyclingFunctionalThresholdPower:
                if #available(iOS 16.0, *) {
                    return HKUnit.watt()
                } else {
                    throw HealthKitError.notAvailable(
                        "\(type) is not available for the current iOS"
                    )
                }
            case .physicalEffort:
                return HKUnit.kilocalorie().unitDivided(
                    by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: HKUnit.hour())
                )
            case .workoutEffortScore,
                 .estimatedWorkoutEffortScore:
                if #available(iOS 18.0, *) {
                    return HKUnit.appleEffortScore()
                } else {
                    throw HealthKitError.notAvailable(
                        "\(type) is not available for the current iOS"
                    )
                }
            }
        }
    }
    /// Parses the unit string and checks that it fits the type, so HealthKit never raises on it
    func compatibleUnit(from unitString: String) throws -> HKUnit {
        let unit = try HKUnit.parsed(from: unitString)
        guard `is`(compatibleWith: unit) else {
            throw HealthKitError.invalidValue(
                "Unit \(unitString) is not compatible with \(identifier)"
            )
        }
        return unit
    }

    var statisticsOptions: HKStatisticsOptions {
        switch aggregationStyle {
        case .cumulative:
            return .cumulativeSum
        case .discreteArithmetic,
             .discreteTemporallyWeighted,
             .discreteEquivalentContinuousLevel:
            return [.discreteAverage, .discreteMin, .discreteMax, .mostRecent]
        @unknown default:
            return []
        }
    }
}
