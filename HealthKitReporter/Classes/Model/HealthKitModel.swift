//
//  Model.swift
//  HealthKitReporter
//
//  Created by Florian on 14.09.20.
//

import Foundation
import HealthKit

public protocol Sample: Codable {
    var identifier: String { get }
}

public struct Statistics: Sample {
    public let identifier: String
    let startDate: String?
    let endDate: String?
    let harmonized: HKStatistics.Harmonized
    let sources: [Source]?

    init(statistics: HKStatistics) throws {
        self.identifier = statistics.quantityType.identifier
        self.startDate = statistics.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = statistics.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.sources = statistics.sources?.map { Source(source: $0 )}
        self.harmonized = try statistics.harmonize()
    }
}

public struct HeartbeatSerie: Codable {
    let ibiArray: [Double]
    let indexArray: [Int]
}

public struct ActivitySummary: Sample {
    public let identifier: String
    let date: String?
    let harmonized: HKActivitySummary.Harmonized

    init(activitySummary: HKActivitySummary) throws {
        self.identifier = HealthKitType
            .activitySummary
            .rawValue?
            .identifier ?? "HKActivitySummaryType"
        self.date = activitySummary
            .dateComponents(for: Calendar.current)
            .date?
            .formatted(with: Date.yyyyMMddTHHmmssZZZZZ)
        self.harmonized = try activitySummary.harmonize()
    }
}

public struct Quantitiy: Sample {
    public let identifier: String
    let startDate: String?
    let endDate: String?
    let device: Device?
    let sourceRevision: SourceRevision
    let harmonized: HKQuantitySample.Harmonized

    init(quantitySample: HKQuantitySample) throws {
        self.identifier = quantitySample.quantityType.identifier
        self.startDate = quantitySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = quantitySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: quantitySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: quantitySample.sourceRevision)
        self.harmonized = try quantitySample.harmonize()
    }
}
public struct Category: Sample {
    public let identifier: String
    let startDate: String?
    let endDate: String?
    let device: Device?
    let sourceRevision: SourceRevision
    let harmonized: HKCategorySample.Harmonized

    init(categorySample: HKCategorySample) throws {
        self.identifier = categorySample.categoryType.identifier
        self.startDate = categorySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = categorySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: categorySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: categorySample.sourceRevision)
        self.harmonized = try categorySample.harmonize()
    }
}
@available(iOS 14.0, *)
public struct Electrocardiogram: Sample {
    public let identifier: String
    let startDate: String?
    let endDate: String?
    let device: Device?
    let sourceRevision: SourceRevision
    let numberOfMeasurements: Int
    let harmonized: HKElectrocardiogram.Harmonized

    init(electrocardiogram: HKElectrocardiogram) throws {
        self.identifier = HealthKitType
            .electrocardiogramType
            .rawValue?
            .identifier ?? "HKElectrocardiogram"
        self.startDate = electrocardiogram.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = electrocardiogram.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: electrocardiogram.device)
        self.numberOfMeasurements = electrocardiogram.numberOfVoltageMeasurements
        self.sourceRevision = SourceRevision(sourceRevision: electrocardiogram.sourceRevision)
        self.harmonized = try electrocardiogram.harmonize()
    }
}
public struct Characteristics: Codable {
    let biologicalSex: String
    let birthday: String?
    let bloodType: String
    let skinType: String

    init(
        biologicalSex: HKBiologicalSexObject,
        birthday: DateComponents,
        bloodType: HKBloodTypeObject,
        skinType: HKFitzpatrickSkinTypeObject
    ) {
        self.biologicalSex = biologicalSex.biologicalSex.string
        self.birthday = birthday.date?.formatted(with: Date.yyyyMMdd)
        self.bloodType = bloodType.bloodType.string
        self.skinType = skinType.skinType.string
    }
}
public struct Source: Codable {
    let name: String
    let bundleIdentifier: String

    init(source: HKSource) {
        self.name = source.name
        self.bundleIdentifier = source.bundleIdentifier
    }
}
public struct Device: Codable {
    let name: String?
    let manufacturer: String?
    let model: String?
    let hardwareVersion: String?
    let firmwareVersion: String?
    let softwareVersion: String?
    let localIdentifier: String?
    let udiDeviceIdentifier: String?

    init(device: HKDevice?) {
        self.name = device?.name
        self.manufacturer = device?.manufacturer
        self.model = device?.model
        self.hardwareVersion = device?.hardwareVersion
        self.firmwareVersion = device?.firmwareVersion
        self.softwareVersion = device?.softwareVersion
        self.localIdentifier = device?.localIdentifier
        self.udiDeviceIdentifier = device?.udiDeviceIdentifier
    }
}
public struct SourceRevision: Codable {
    let source: Source
    let version: String?
    let productType: String?
    let systemVersion: String

    init(sourceRevision: HKSourceRevision) {
        self.source = Source(source: sourceRevision.source)
        self.version = sourceRevision.version
        self.productType = sourceRevision.productType
        self.systemVersion = sourceRevision.systemVersion
    }
}
public struct Correlation: Sample {
    public let identifier: String
    let harmonized: HKCorrelation.Harmonized

    init(correlation: HKCorrelation) throws {
        self.identifier = correlation.correlationType.identifier
        self.harmonized = try correlation.harmonize()
    }
}
public struct Workout: Sample {
    public let identifier: String
    let startDate: String?
    let endDate: String?
    let workoutName: String
    let device: Device?
    let sourceRevision: SourceRevision
    let duration: Double
    let events: [WorkoutEvent]
    let harmonized: HKWorkout.Harmonized

    init(workout: HKWorkout) throws {
        self.identifier = workout.sampleType.identifier
        self.startDate = workout.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = workout.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: workout.device)
        self.sourceRevision = SourceRevision(sourceRevision: workout.sourceRevision)
        self.workoutName = String(describing: workout.workoutActivityType)
        self.duration = workout.duration
        self.events = workout.workoutEvents?.map { WorkoutEvent(workoutEvent: $0) } ?? []
        self.harmonized = try workout.harmonize()
    }
}
public struct WorkoutEvent: Codable {
    let type: String
    let startDate: String?
    let endDate: String?
    let duration: Double

    init(workoutEvent: HKWorkoutEvent) {
        self.type = String(describing: workoutEvent.type)
        self.startDate = workoutEvent
            .dateInterval
            .start
            .formatted(with: Date.yyyyMMddTHHmmssZZZZZ)
        self.endDate = workoutEvent
            .dateInterval
            .end
            .formatted(with: Date.yyyyMMddTHHmmssZZZZZ)
        self.duration = workoutEvent.dateInterval.duration
    }
}
