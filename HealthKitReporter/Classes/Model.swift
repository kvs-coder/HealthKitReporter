//
//  Model.swift
//  HealthKitReporter
//
//  Created by Florian on 14.09.20.
//

import Foundation
import HealthKit

protocol HealthKitParsable {
    func parsed() throws -> (value: Double, unit: String)
}

public struct Statistics: Codable {
    let identifier: String
    let value: Double
    let startDate: String?
    let endDate: String?
    let unit: String

    init(statistics: HKStatistics) {
        self.identifier = statistics.quantityType.identifier
        self.startDate = statistics.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = statistics.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        do {
            let (value, unit) = try statistics.parsed()
            self.value = value
            self.unit = unit
        } catch {
            self.value = -1
            self.unit = "unknown"
        }
    }
}
public protocol Serie: Codable {

}

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

public protocol Sample: Codable {
    var identifier: String { get }
    var value: Double { get }
    var startDate: String? { get }
    var endDate: String? { get }
}

public struct Quantitiy: Sample {
    public let identifier: String
    public let value: Double
    public let startDate: String?
    public let endDate: String?
    let unit: String

    init(quantitySample: HKQuantitySample) {
        self.identifier = quantitySample.quantityType.identifier
        self.startDate = quantitySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = quantitySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        do {
            let (value, unit) = try quantitySample.parsed()
            self.value = value
            self.unit = unit
        } catch {
            self.value = -1
            self.unit = "unknown"
        }
    }
}
public struct Category: Sample {
    public let identifier: String
    public let value: Double
    public let startDate: String?
    public let endDate: String?
    let status: String

    init(categorySample: HKCategorySample) {
        self.identifier = categorySample.categoryType.identifier
        self.startDate = categorySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = categorySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        do {
            let (value, status) = try categorySample.parsed()
            self.value = value
            self.status = status
        } catch {
            self.value = -1
            self.status = "unknown"
        }
    }
}
@available(iOS 14.0, *)
public struct Electrocardiogram: Sample {
    public let identifier: String
    public let value: Double
    public let startDate: String?
    public let endDate: String?
    let unit: String
    let classification: String
    let numberOfMeasurements: Int
    let frequency: Double
    let frequencyUnit: String
    let symptomStatus: String

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
        self.classification = electrocardiogram.classification()
        self.symptomStatus = electrocardiogram.symptomsStatus()
        self.numberOfMeasurements = electrocardiogram.numberOfVoltageMeasurements
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
