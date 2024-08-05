//
//  Extensions+HKSample.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

extension HKSample {
    func parsed() throws -> Sample {
        if let quantitiy = self as? HKQuantitySample {
            return try Quantity(quantitySample: quantitiy)
        }
        if let category = self as? HKCategorySample {
            return try Category(categorySample: category)
        }
        if let workout = self as? HKWorkout {
            return try Workout(workout: workout)
        }
        if let correlation = self as? HKCorrelation {
            return try Correlation(correlation: correlation)
        }
        if #available(iOS 14.0, *) {
            if let electrocardiogram = self as? HKElectrocardiogram {
                return try Electrocardiogram(electrocardiogram: electrocardiogram, voltageMeasurements: [])
            }
        }
        if #available(iOS 12.0, *) {
            if let clinicalRecord = self as? HKClinicalRecord {
                return try ClinicalRecord(clinicalRecord: clinicalRecord)
            }
        }
        throw HealthKitError.parsingFailed("HKSample could not be parsed")
    }
}
