//
//  Extensions+HKWorkout.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

// MARK: - Harmonizable
extension HKWorkout: Harmonizable {
    typealias Harmonized = Workout.Harmonized

    func harmonize() throws -> Harmonized {
        let energyUnit = HKUnit.largeCalorie()
        let distanceUnit = HKUnit.meter()
        let countUnit = HKUnit.count()
        return Harmonized(
            value: Int(workoutActivityType.rawValue),
            description: workoutActivityType.label,
            totalEnergyBurned: total(totalEnergyBurned, of: [.activeEnergyBurned], in: energyUnit),
            totalEnergyBurnedUnit: energyUnit.unitString,
            totalDistance: total(totalDistance, of: distanceTypes, in: distanceUnit),
            totalDistanceUnit: distanceUnit.unitString,
            totalSwimmingStrokeCount: total(
                totalSwimmingStrokeCount,
                of: [.swimmingStrokeCount],
                in: countUnit
            ),
            totalSwimmingStrokeCountUnit: countUnit.unitString,
            totalFlightsClimbed: total(totalFlightsClimbed, of: [.flightsClimbed], in: countUnit),
            totalFlightsClimbedUnit: countUnit.unitString,
            metadata: metadata?.asMetadata
        )
    }

    /// Every distance type a workout can record, in the order a total is looked up
    private var distanceTypes: [HKQuantityTypeIdentifier] {
        var identifiers: [HKQuantityTypeIdentifier] = [
            .distanceWalkingRunning,
            .distanceCycling,
            .distanceSwimming,
            .distanceWheelchair,
            .distanceDownhillSnowSports
        ]
        if #available(iOS 18.0, watchOS 11.0, *) {
            identifiers += [
                .distanceCrossCountrySkiing,
                .distancePaddleSports,
                .distanceRowing,
                .distanceSkatingSports
            ]
        }
        return identifiers
    }

    /// The deprecated total when set, otherwise the summed statistics,
    /// which activity based workouts use (iOS 16+)
    private func total(
        _ deprecatedTotal: HKQuantity?,
        of identifiers: [HKQuantityTypeIdentifier],
        in unit: HKUnit
    ) -> Double? {
        if let deprecatedTotal = deprecatedTotal {
            return deprecatedTotal.doubleValue(for: unit)
        }
        guard #available(iOS 16.0, watchOS 9.0, *) else {
            return nil
        }
        return identifiers
            .lazy
            .compactMap { self.statistics(for: HKQuantityType($0))?.sumQuantity() }
            .first?
            .doubleValue(for: unit)
    }
}
