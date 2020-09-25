//
//  Model.swift
//  HealthKitReporter
//
//  Created by Florian on 14.09.20.
//

import Foundation
import HealthKit

protocol HealthKitParsable {
    associatedtype Parseble where Parseble: Sample
    func parsed() throws -> Parseble
}

public struct Statistics: Sample {
    public let identifier: String
    public let value: Double
    public let startDate: String?
    public let endDate: String?
    public let unit: String
    let sources: [Source]?

    init(statistics: HKStatistics, value: Double, unit: HKUnit) {
        self.identifier = statistics.quantityType.identifier
        self.startDate = statistics.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = statistics.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.sources = statistics.sources?.map { Source(source: $0 )}
        self.unit = unit.unitString
        self.value = value
    }
}
public protocol Serie: Codable {}

public struct HeartbeatSerie: Serie {
    let ibiArray: [Double]
    let indexArray: [Int]
}

public struct ActivitySummary: Codable {
    let activeEnergyBurned: Double
    let activeEnergyBurnedGoal: Double
    let activeEnergyBurnedUnit: String
    let appleExerciseTime: Double
    let appleExerciseTimeGoal: Double
    let appleExerciseTimeUnit: String
    let appleStandHours: Double
    let appleStandHoursGoal: Double
    let appleStandHoursUnit: String
    let date: String?

    init(activitySummary: HKActivitySummary) {
        self.date = activitySummary
            .dateComponents(for: Calendar.current)
            .date?
            .formatted(with: Date.yyyyMMddTHHmmssZZZZZ)
        let activeEnergyBurned = activitySummary.activeEnergyBurned()
        self.activeEnergyBurned = activeEnergyBurned.value
        self.activeEnergyBurnedGoal = activeEnergyBurned.goal
        self.activeEnergyBurnedUnit = activeEnergyBurned.unit
        let appleExerciseTime = activitySummary.appleExerciseTime()
        self.appleExerciseTime = appleExerciseTime.value
        self.appleExerciseTimeGoal = appleExerciseTime.goal
        self.appleExerciseTimeUnit = appleExerciseTime.unit
        let appleStandHours = activitySummary.appleStandHours()
        self.appleStandHours = appleStandHours.value
        self.appleStandHoursGoal = appleStandHours.goal
        self.appleStandHoursUnit = appleStandHours.unit
    }
}

public struct Quantitiy: Sample {
    public let identifier: String
    public let value: Double
    public let startDate: String?
    public let endDate: String?
    public let unit: String
    let device: Device?
    let sourceRevision: SourceRevision

    init(quantitySample: HKQuantitySample, unit: HKUnit) {
        self.identifier = quantitySample.quantityType.identifier
        self.startDate = quantitySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = quantitySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: quantitySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: quantitySample.sourceRevision)
        self.unit = unit.unitString
        self.value = quantitySample.quantity.doubleValue(for: unit)
    }
}
public struct Category: Sample {
    public let identifier: String
    public let value: Double
    public let startDate: String?
    public let endDate: String?
    public let unit: String
    let device: Device?
    let sourceRevision: SourceRevision

    init(categorySample: HKCategorySample, value: Double, unit: String) {
        self.identifier = categorySample.categoryType.identifier
        self.startDate = categorySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = categorySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.device = Device(device: categorySample.device)
        self.sourceRevision = SourceRevision(sourceRevision: categorySample.sourceRevision)
        self.value = value
        self.unit = unit
    }
}
@available(iOS 14.0, *)
public struct Electrocardiogram: Sample {
    public let identifier: String
    public let value: Double
    public let startDate: String?
    public let endDate: String?
    public let unit: String
    let classification: String
    let numberOfMeasurements: Int
    let frequency: Double
    let frequencyUnit: String
    let symptomStatus: String
    let device: Device?
    let sourceRevision: SourceRevision

    init(electrocardiogram: HKElectrocardiogram) {
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
        self.classification = electrocardiogram.classification()
        self.symptomStatus = electrocardiogram.symptomsStatus()
        self.numberOfMeasurements = electrocardiogram.numberOfVoltageMeasurements
        self.sourceRevision = SourceRevision(sourceRevision: electrocardiogram.sourceRevision)
        do {
            let averageHeartRate = try electrocardiogram.averageHeartRate()
            let samplingFrequency = try electrocardiogram.samplingFrequency()
            self.value = averageHeartRate.value
            self.unit = averageHeartRate.unit
            self.frequency = samplingFrequency.value
            self.frequencyUnit = samplingFrequency.unit
        } catch {
            self.value = -1
            self.unit = "unknown"
            self.frequency = -1
            self.frequencyUnit = "unknown"
        }
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
public struct Correlation: Codable {
    public let identifier: String
    var quantitySamples: [Quantitiy] = []
    var categorySamples: [Category] = []

    init(correlation: HKCorrelation) {
        self.identifier = correlation.correlationType.identifier
    }
}

public protocol Sample: Codable {
    var identifier: String { get }
    var value: Double { get }
    var startDate: String? { get }
    var endDate: String? { get }
    var unit: String { get }
}
