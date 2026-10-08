//
//  DemoSamples.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit
import HealthKitReporter
import struct HealthKitReporter.Category

/// Builds the payloads the demo writes, each marked so the demo can find and delete its own data
final class DemoSamples {
    /// Prefix of **HKMetadataKeyExternalUUID** on every sample written with these payloads
    let marker: String

    init(marker: String) {
        self.marker = marker
    }

    /// HealthKit sets the real source on save; the payload only needs a placeholder
    var sourceRevision: SourceRevision {
        return SourceRevision(
            source: Source(name: "HealthKitReporter Example", bundleIdentifier: Bundle.main.bundleIdentifier ?? ""),
            version: nil,
            productType: nil,
            systemVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            operatingSystem: SourceRevision.OperatingSystem(majorVersion: 26, minorVersion: 0, patchVersion: 0)
        )
    }

    /// Unique per sample, starting with **marker**
    var metadata: Metadata {
        return [HKMetadataKeyExternalUUID: .string("\(marker)\(UUID().uuidString)")]
    }

    func quantity(
        _ type: QuantityType,
        value: Double,
        unit: String,
        start: Date,
        end: Date? = nil,
        metadata extra: [String: Metadata.Value] = [:]
    ) -> Quantity {
        return Quantity(
            identifier: type.identifier ?? "",
            startTimestamp: start.timeIntervalSince1970,
            endTimestamp: (end ?? start).timeIntervalSince1970,
            device: nil,
            sourceRevision: sourceRevision,
            harmonized: Quantity.Harmonized(
                value: value,
                unit: unit,
                metadata: Metadata(metadata.values.merging(extra) { first, _ in first })
            )
        )
    }

    func category(
        _ type: CategoryType,
        value: Int,
        start: Date,
        end: Date,
        metadata extra: [String: Metadata.Value] = [:]
    ) -> Category {
        return Category(
            identifier: type.identifier ?? "",
            startTimestamp: start.timeIntervalSince1970,
            endTimestamp: end.timeIntervalSince1970,
            device: nil,
            sourceRevision: sourceRevision,
            harmonized: Category.Harmonized(
                value: value,
                description: "",
                detail: "",
                metadata: Metadata(metadata.values.merging(extra) { first, _ in first })
            )
        )
    }

    func bloodPressure(systolic: Double, diastolic: Double, at date: Date) -> Correlation {
        return correlation(
            .bloodPressure,
            at: date,
            quantities: [
                quantity(.bloodPressureSystolic, value: systolic, unit: "mmHg", start: date),
                quantity(.bloodPressureDiastolic, value: diastolic, unit: "mmHg", start: date)
            ]
        )
    }

    func food(kilocalories: Double, protein: Double, at date: Date) -> Correlation {
        return correlation(
            .food,
            at: date,
            quantities: [
                quantity(.dietaryEnergyConsumed, value: kilocalories, unit: "kcal", start: date),
                quantity(.dietaryProtein, value: protein, unit: "g", start: date)
            ]
        )
    }

    /// A run with a pause and a resume
    func workout(
        _ activity: HKWorkoutActivityType = .running,
        named name: String = "Running",
        start: Date,
        minutes: Double
    ) -> Workout {
        let end = start.addingTimeInterval(minutes * 60)
        let pause = start.addingTimeInterval(minutes * 20)
        let resume = start.addingTimeInterval(minutes * 25)
        return Workout(
            identifier: WorkoutType.workoutType.identifier ?? "",
            startTimestamp: start.timeIntervalSince1970,
            endTimestamp: end.timeIntervalSince1970,
            device: nil,
            sourceRevision: sourceRevision,
            duration: minutes * 60,
            workoutEvents: [
                event(.pause, named: "Pause", at: pause),
                event(.resume, named: "Resume", at: resume)
            ],
            harmonized: Workout.Harmonized(
                value: Int(activity.rawValue),
                description: name,
                totalEnergyBurned: minutes * 10,
                totalEnergyBurnedUnit: "kcal",
                totalDistance: minutes * 160,
                totalDistanceUnit: "m",
                totalSwimmingStrokeCount: nil,
                totalSwimmingStrokeCountUnit: "count",
                totalFlightsClimbed: nil,
                totalFlightsClimbedUnit: "count",
                metadata: metadata
            )
        )
    }

    private func correlation(_ type: CorrelationType, at date: Date, quantities: [Quantity]) -> Correlation {
        return Correlation(
            identifier: type.identifier ?? "",
            startTimestamp: date.timeIntervalSince1970,
            endTimestamp: date.timeIntervalSince1970,
            device: nil,
            sourceRevision: sourceRevision,
            harmonized: Correlation.Harmonized(quantitySamples: quantities, categorySamples: [], metadata: metadata)
        )
    }
    private func event(_ type: HKWorkoutEventType, named name: String, at date: Date) -> WorkoutEvent {
        return WorkoutEvent(
            startTimestamp: date.timeIntervalSince1970,
            endTimestamp: date.timeIntervalSince1970,
            duration: 0,
            harmonized: WorkoutEvent.Harmonized(value: type.rawValue, description: name, metadata: nil)
        )
    }
}
