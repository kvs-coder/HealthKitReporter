//
//  Extensions+HKSample.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

extension HKSample {
    /// The payload of the sample. Series samples come without their measurements, voltages or locations,
    /// which need a query of their own (heartbeat series, workout route, electrocardiogram)
    func parsed() throws -> Sample {
        switch self {
        case let quantity as HKQuantitySample:
            return try Quantity(quantitySample: quantity)
        case let category as HKCategorySample:
            return try Category(categorySample: category)
        case let workout as HKWorkout:
            return try Workout(workout: workout)
        case let correlation as HKCorrelation:
            return try Correlation(correlation: correlation)
        case let electrocardiogram as HKElectrocardiogram:
            return try Electrocardiogram(electrocardiogram: electrocardiogram, voltageMeasurements: [])
        case let audiogram as HKAudiogramSample:
            return try Audiogram(audiogramSample: audiogram)
        case let heartbeatSeries as HKHeartbeatSeriesSample:
            return HeartbeatSeries(sample: heartbeatSeries, measurements: [])
        case let route as HKWorkoutRoute:
            return WorkoutRoute(sample: route, routes: [])
        default:
            return try parsedNewerOrPlatformSample()
        }
    }

    /// Samples available only on iOS or on newer OS versions
    private func parsedNewerOrPlatformSample() throws -> Sample {
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
        if #available(iOS 18.0, watchOS 11.0, *), let stateOfMind = self as? HKStateOfMind {
            return StateOfMind(stateOfMind: stateOfMind)
        }
        if #available(iOS 18.0, watchOS 11.0, *), let assessment = self as? HKScoredAssessment {
            return try ScoredAssessment(assessment: assessment)
        }
        if #available(iOS 26.0, watchOS 26.0, *), let doseEvent = self as? HKMedicationDoseEvent {
            return MedicationDoseEvent(doseEvent: doseEvent)
        }
        throw HealthKitError.parsingFailed("HKSample could not be parsed")
    }
}
