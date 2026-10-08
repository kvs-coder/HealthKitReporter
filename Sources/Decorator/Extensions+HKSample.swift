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
        if let electrocardiogram = self as? HKElectrocardiogram {
            return try Electrocardiogram(electrocardiogram: electrocardiogram, voltageMeasurements: [])
        }
        #if os(iOS)
        if let clinicalRecord = self as? HKClinicalRecord {
            return try ClinicalRecord(clinicalRecord: clinicalRecord)
        }
        if let document = self as? HKCDADocumentSample {
            return CDADocument(documentSample: document)
        }
        #endif
        if #available(iOS 16.0, watchOS 9.0, *), let visionPrescription = self as? HKVisionPrescription {
            return try VisionPrescription(visionPrescription: visionPrescription)
        }
        throw HealthKitError.parsingFailed("HKSample could not be parsed")
    }
}
