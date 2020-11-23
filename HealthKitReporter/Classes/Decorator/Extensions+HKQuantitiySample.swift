//
//  Extensions+HKQuantitiySample.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import Foundation
import HealthKit

extension HKQuantitySample: Harmonizable {
    typealias Harmonized = Quantity.Harmonized

    func harmonize() throws -> Harmonized {
        switch self.quantityType {
        case HKObjectType.quantityType(forIdentifier: .stepCount):
            return quantity(unit: HKUnit.count())
        case HKObjectType.quantityType(forIdentifier: .distanceCycling),
             HKObjectType.quantityType(forIdentifier: .distanceSwimming),
             HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning):
            return quantity(unit: HKUnit.meter())
        case HKObjectType.quantityType(forIdentifier: .heartRate):
            return quantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case HKObjectType.quantityType(forIdentifier: .respiratoryRate):
            return quantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
        case HKObjectType.quantityType(forIdentifier: .basalEnergyBurned):
            return quantity(unit: HKUnit.largeCalorie())
        case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned):
            return quantity(unit: HKUnit.largeCalorie())
        case HKObjectType.quantityType(forIdentifier: .flightsClimbed):
            return quantity(unit: HKUnit.count())
        case HKObjectType.quantityType(forIdentifier: .basalBodyTemperature):
            return quantity(unit: HKUnit.kelvin())
        case HKObjectType.quantityType(forIdentifier: .oxygenSaturation):
            return quantity(unit: HKUnit.percent())
        case HKObjectType.quantityType(forIdentifier: .bodyTemperature):
            return quantity(unit: HKUnit.kelvin())
        case HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic):
            return quantity(unit: HKUnit.millimeterOfMercury())
        case HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic):
            return quantity(unit: HKUnit.millimeterOfMercury())
        case HKObjectType.quantityType(forIdentifier: .bloodGlucose):
            return quantity(unit: HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.liter()))
        case HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed):
            return quantity(unit: HKUnit.largeCalorie())
        case HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryFiber):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietarySugar):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryFatTotal):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryFatSaturated):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryProtein):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminA):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryThiamin):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryRiboflavin):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryNiacin):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryPantothenicAcid):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminB6):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminB12):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminC):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminD):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminE):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryVitaminK):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryCalcium):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryIron):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryMagnesium):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryManganese):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryWater):
            return quantity(unit: HKUnit.fluidOunceUS())
        case HKObjectType.quantityType(forIdentifier: .dietaryPhosphorus):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryPotassium):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietarySodium):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryZinc):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .dietaryIodine):
            return quantity(unit: HKUnit.gram())
        case HKObjectType.quantityType(forIdentifier: .oxygenSaturation):
            return quantity(unit: HKUnit.percent())
        case HKObjectType.quantityType(forIdentifier: .peakExpiratoryFlowRate):
            return quantity(unit: HKUnit.liter().unitDivided(by: HKUnit.minute()))
        default:
            throw HealthKitError.invalidType(
                "Invalid type: \(self.quantityType)"
            )
        }
    }

    private func quantity(unit: HKUnit) -> Harmonized {
        let value = self.quantity.doubleValue(for: unit)
        return Harmonized(
            value: value,
            unit: unit.unitString,
            metadata: self.metadata?.compactMapValues { String(describing: $0 )})
    }
}
