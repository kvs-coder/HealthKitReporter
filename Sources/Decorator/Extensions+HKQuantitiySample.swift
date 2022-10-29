//
//  Extensions+HKQuantitiySample.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

// SI parsing
extension HKQuantitySample: Harmonizable {
    typealias Harmonized = Quantity.Harmonized

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
            return quantity(unit: HKUnit.count())
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
            return quantity(unit: HKUnit.meter())
        case .heartRate,
             .respiratoryRate,
             .restingHeartRate,
             .walkingHeartRateAverage,
             .heartRateRecoveryOneMinute:
            return quantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case .basalEnergyBurned,
             .activeEnergyBurned,
             .dietaryEnergyConsumed:
            if #available(iOS 11.0, *) {
                return quantity(unit: HKUnit.largeCalorie())
            } else {
                return quantity(unit: HKUnit.kilocalorie())
            }
        case .basalBodyTemperature,
             .bodyTemperature,
             .appleSleepingWristTemperature,
             .waterTemperature:
            return quantity(unit: HKUnit.kelvin())
        case .oxygenSaturation,
             .bodyFatPercentage,
             .walkingDoubleSupportPercentage,
             .walkingAsymmetryPercentage,
             .peripheralPerfusionIndex,
             .bloodAlcoholContent,
             .appleWalkingSteadiness,
             .atrialFibrillationBurden:
            return quantity(unit: HKUnit.percent())
        case .bloodPressureSystolic,
             .bloodPressureDiastolic:
            return quantity(unit: HKUnit.millimeterOfMercury())
        case .bloodGlucose:
            return quantity(unit: HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.liter()))
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
            return quantity(unit: HKUnit.gram())
        case .peakExpiratoryFlowRate:
            return quantity(unit: HKUnit.liter().unitDivided(by: HKUnit.minute()))
        case .bodyMass,
             .leanBodyMass:
            return quantity(unit: HKUnit.gramUnit(with: .kilo))
        case .appleExerciseTime,
             .appleStandTime,
             .appleMoveTime,
             .runningGroundContactTime:
            return quantity(unit: HKUnit.second())
        case .vo2Max:
            return quantity(
                unit: HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: HKUnit.minute()))
            )
        case .walkingSpeed,
             .stairAscentSpeed,
             .stairDescentSpeed,
             .runningSpeed:
            return quantity(unit: HKUnit.meter().unitDivided(by: HKUnit.second()))
        case .heartRateVariabilitySDNN:
            return quantity(unit: HKUnit.secondUnit(with: .milli))
        case .electrodermalActivity:
            return quantity(unit: HKUnit.siemen())
        case .insulinDelivery:
            if #available(iOS 11.0, *) {
                return quantity(unit: HKUnit.internationalUnit())
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        case .forcedVitalCapacity,
             .forcedExpiratoryVolume1:
            return quantity(unit: HKUnit.literUnit(with: .milli))
        case .environmentalAudioExposure,
             .headphoneAudioExposure:
            return quantity(unit: HKUnit.pascal())
        case .runningPower:
            if #available(iOS 16.0, *) {
                return quantity(unit: HKUnit.watt())
            } else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
        }
    }

    private func quantity(unit: HKUnit) -> Harmonized {
        let value = quantity.doubleValue(for: unit)
        return Harmonized(
            value: value,
            unit: unit.unitString,
            metadata: metadata?.asMetadata
        )
    }
}
