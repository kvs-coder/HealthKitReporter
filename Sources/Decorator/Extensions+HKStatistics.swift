//
//  Extensions+HKStatistics.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

// SI parsing
extension HKStatistics: Harmonizable {
    typealias Harmonized = Statistics.Harmonized

    func harmonize() throws -> Harmonized {
        let type = try quantityType.parsed()
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
             .numberOfAlcoholicBeverages:
            return statistics(unit: HKUnit.count())
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
             .underwaterDepth:
            return statistics(unit: HKUnit.meter())
        case .heartRate,
             .respiratoryRate,
             .restingHeartRate,
             .walkingHeartRateAverage,
             .heartRateRecoveryOneMinute:
            return statistics(unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case .basalEnergyBurned,
             .activeEnergyBurned,
             .dietaryEnergyConsumed:
            if #available(iOS 11.0, *) {
                return statistics(unit: HKUnit.largeCalorie())
            } else {
                return statistics(unit: HKUnit.kilocalorie())
            }
        case .basalBodyTemperature,
             .bodyTemperature,
             .appleSleepingWristTemperature,
             .waterTemperature:
            return statistics(unit: HKUnit.kelvin())
        case .oxygenSaturation,
             .bodyFatPercentage,
             .walkingDoubleSupportPercentage,
             .walkingAsymmetryPercentage,
             .peripheralPerfusionIndex,
             .bloodAlcoholContent,
             .appleWalkingSteadiness,
             .atrialFibrillationBurden:
            return statistics(unit: HKUnit.percent())
        case .bloodPressureSystolic,
             .bloodPressureDiastolic:
            return statistics(unit: HKUnit.millimeterOfMercury())
        case .bloodGlucose:
            return statistics(unit: HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.liter()))
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
             .dietaryWater,
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
            return statistics(unit: HKUnit.gram())
        case .peakExpiratoryFlowRate:
            return statistics(unit: HKUnit.liter().unitDivided(by: HKUnit.minute()))
        case .bodyMass,
             .leanBodyMass:
            return statistics(unit: HKUnit.gramUnit(with: .kilo))
        case .appleExerciseTime,
             .appleStandTime,
             .appleMoveTime,
             .runningGroundContactTime:
            return statistics(unit: HKUnit.second())
        case .vo2Max:
            return statistics(
                unit: HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: HKUnit.minute()))
            )
        case .walkingSpeed,
             .stairAscentSpeed,
             .stairDescentSpeed,
             .runningSpeed:
            return statistics(unit: HKUnit.meter().unitDivided(by: HKUnit.second()))
        case .heartRateVariabilitySDNN:
            return statistics(unit: HKUnit.secondUnit(with: .milli))
        case .electrodermalActivity:
            return statistics(unit: HKUnit.siemen())
        case .insulinDelivery:
            if #available(iOS 11.0, *) {
                return statistics(unit: HKUnit.internationalUnit())
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .forcedVitalCapacity,
             .forcedExpiratoryVolume1:
            return statistics(unit: HKUnit.literUnit(with: .milli))
        case .environmentalAudioExposure,
             .headphoneAudioExposure:
            return statistics(unit: HKUnit.pascal())
        case .runningPower:
            if #available(iOS 16.0, *) {
                return statistics(unit: HKUnit.watt())
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        }
    }
    
    private func statistics(unit: HKUnit) -> Harmonized {
        if #available(iOS 12.0, *) {
            return Harmonized(
                summary: sumQuantity()?.doubleValue(for: unit),
                average: averageQuantity()?.doubleValue(for: unit),
                recent: mostRecentQuantity()?.doubleValue(for: unit),
                min: minimumQuantity()?.doubleValue(for: unit),
                max: maximumQuantity()?.doubleValue(for: unit),
                unit: unit.unitString
            )
        } else {
            return Harmonized(
                summary: sumQuantity()?.doubleValue(for: unit),
                average: averageQuantity()?.doubleValue(for: unit),
                recent: nil,
                min: minimumQuantity()?.doubleValue(for: unit),
                max: maximumQuantity()?.doubleValue(for: unit),
                unit: unit.unitString
            )
        }
    }
}
