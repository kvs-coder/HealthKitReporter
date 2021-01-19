//
//  Extensions+HKStatistics.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import Foundation
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
             .uvExposure:
            return statistics(unit: HKUnit.count())
        case .distanceCycling,
             .distanceSwimming,
             .distanceWalkingRunning,
             .distanceWheelchair,
             .distanceDownhillSnowSports,
             .height,
             .waistCircumference,
             .walkingStepLength,
             .sixMinuteWalkTestDistance:
            return statistics(unit: HKUnit.meter())
        case .heartRate,
             .respiratoryRate,
             .restingHeartRate,
             .walkingHeartRateAverage:
            return statistics(unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case .basalEnergyBurned,
             .activeEnergyBurned,
             .dietaryEnergyConsumed:
            return statistics(unit: HKUnit.largeCalorie())
        case .basalBodyTemperature,
             .bodyTemperature:
            return statistics(unit: HKUnit.kelvin())
        case .oxygenSaturation,
             .bodyFatPercentage,
             .walkingDoubleSupportPercentage,
             .walkingAsymmetryPercentage,
             .peripheralPerfusionIndex,
             .bloodAlcoholContent:
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
             .appleStandTime:
            return statistics(unit: HKUnit.second())
        case .vo2Max:
            return statistics(
                unit: HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: HKUnit.minute()))
            )
        case .walkingSpeed,
             .stairAscentSpeed,
             .stairDescentSpeed:
            return statistics(unit: HKUnit.meter().unitDivided(by: HKUnit.second()))
        case .heartRateVariabilitySDNN:
            return statistics(unit: HKUnit.secondUnit(with: .milli))
        case .electrodermalActivity:
            return statistics(unit: HKUnit.siemen())
        case .insulinDelivery:
            return statistics(unit: HKUnit.internationalUnit())
        case .forcedVitalCapacity,
             .forcedExpiratoryVolume1:
            return statistics(unit: HKUnit.literUnit(with: .milli))
        case .environmentalAudioExposure,
             .headphoneAudioExposure:
            return statistics(unit: HKUnit.pascal())
        }
    }
    
    private func statistics(unit: HKUnit) -> Harmonized {
        return Harmonized(
            summary: sumQuantity()?.doubleValue(for: unit),
            average: averageQuantity()?.doubleValue(for: unit),
            recent: mostRecentQuantity()?.doubleValue(for: unit),
            min: minimumQuantity()?.doubleValue(for: unit),
            max: maximumQuantity()?.doubleValue(for: unit),
            unit: unit.unitString
        )
    }
}
