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
public struct Serie: Codable {

}
public struct Sample: Codable {
    let identifier: String
    let value: Double
    let startDate: String?
    let endDate: String?
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
    init(categorySample: HKCategorySample) {
        self.identifier = categorySample.categoryType.identifier
        self.startDate = categorySample.startDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        self.endDate = categorySample.endDate.formatted(
            with: Date.yyyyMMddTHHmmssZZZZZ
        )
        do {
            let (value, unit) = try categorySample.parsed()
            self.value = value
            self.unit = unit
        } catch {
            self.value = -1
            self.unit = "unknown"
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
