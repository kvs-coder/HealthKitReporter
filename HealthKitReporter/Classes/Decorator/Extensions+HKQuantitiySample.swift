//
//  Extensions+HKQuantitiySample.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import Foundation
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
             .uvExposure:
            return quantity(unit: HKUnit.count())
        case .distanceCycling,
             .distanceSwimming,
             .distanceWalkingRunning,
             .distanceWheelchair,
             .distanceDownhillSnowSports,
             .height,
             .waistCircumference,
             .walkingStepLength,
             .sixMinuteWalkTestDistance:
            return quantity(unit: HKUnit.meter())
        case .heartRate,
             .respiratoryRate,
             .restingHeartRate,
             .walkingHeartRateAverage:
            return quantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case .basalEnergyBurned,
             .activeEnergyBurned,
             .dietaryEnergyConsumed:
            return quantity(unit: HKUnit.largeCalorie())
        case .basalBodyTemperature,
             .bodyTemperature:
            return quantity(unit: HKUnit.kelvin())
        case .oxygenSaturation,
             .bodyFatPercentage,
             .walkingDoubleSupportPercentage,
             .walkingAsymmetryPercentage,
             .peripheralPerfusionIndex,
             .bloodAlcoholContent:
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
             .appleStandTime:
            return quantity(unit: HKUnit.second())
        case .vo2Max:
            return quantity(
                unit: HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: HKUnit.minute()))
            )
        case .walkingSpeed,
             .stairAscentSpeed,
             .stairDescentSpeed:
            return quantity(unit: HKUnit.meter().unitDivided(by: HKUnit.second()))
        case .heartRateVariabilitySDNN:
            return quantity(unit: HKUnit.secondUnit(with: .milli))
        case .electrodermalActivity:
            return quantity(unit: HKUnit.siemen())
        case .insulinDelivery:
            return quantity(unit: HKUnit.internationalUnit())
        case .forcedVitalCapacity,
             .forcedExpiratoryVolume1:
            return quantity(unit: HKUnit.literUnit(with: .milli))
        case .environmentalAudioExposure,
             .headphoneAudioExposure:
            return quantity(unit: HKUnit.pascal())
        }
    }

    private func quantity(unit: HKUnit) -> Harmonized {
        let value = quantity.doubleValue(for: unit)
        return Harmonized(
            value: value,
            unit: unit.unitString,
            metadata: metadata?.compactMapValues { String(describing: $0 )})
    }
}
