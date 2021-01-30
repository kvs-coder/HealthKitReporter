//
//  Electrocardiogram.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

@available(iOS 14.0, *)
public struct Electrocardiogram: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let averageHeartRate: Double
        public let averageHeartRateUnit: String
        public let samplingFrequency: Double
        public let samplingFrequencyUnit: String
        public let classification: String
        public let symptomsStatus: String
        public let metadata: [String: String]?

        public init(
            averageHeartRate: Double,
            averageHeartRateUnit: String,
            samplingFrequency: Double,
            samplingFrequencyUnit: String,
            classification: String,
            symptomsStatus: String,
            metadata: [String: String]?
        ) {
            self.averageHeartRate = averageHeartRate
            self.averageHeartRateUnit = averageHeartRateUnit
            self.samplingFrequency = samplingFrequency
            self.samplingFrequencyUnit = samplingFrequencyUnit
            self.classification = classification
            self.symptomsStatus = symptomsStatus
            self.metadata = metadata
        }
    }
    public struct VoltageMeasurement: Codable {
        public struct Harmonized: Codable {
            public let value: Double
            public let unit: String
        }

        public let harmonized: Harmonized
        public let timeSinceSampleStart: Double

        init(voltageMeasurement: HKElectrocardiogram.VoltageMeasurement) throws {
            self.harmonized = try voltageMeasurement.harmonize()
            self.timeSinceSampleStart = voltageMeasurement.timeSinceSampleStart
        }
    }

    public let uuid: String
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let numberOfMeasurements: Int
    public let harmonized: Harmonized

    public static func collect(
        results: [HKSample]
    ) -> [Electrocardiogram] {
        var samples = [Electrocardiogram]()
        if let electrocardiograms = results as? [HKElectrocardiogram] {
            for electrocardiogram in electrocardiograms {
                do {
                    let sample = try Electrocardiogram(
                        electrocardiogram: electrocardiogram
                    )
                    samples.append(sample)
                } catch {
                    continue
                }
            }
        }
        return samples
    }

    init(electrocardiogram: HKElectrocardiogram) throws {
        self.uuid = electrocardiogram.uuid.uuidString
        self.identifier = ElectrocardiogramType
            .electrocardiogramType
            .original?
            .identifier ?? "HKElectrocardiogram"
        self.startTimestamp = electrocardiogram.startDate.timeIntervalSince1970
        self.endTimestamp = electrocardiogram.endDate.timeIntervalSince1970
        self.device = Device(device: electrocardiogram.device)
        self.numberOfMeasurements = electrocardiogram.numberOfVoltageMeasurements
        self.sourceRevision = SourceRevision(sourceRevision: electrocardiogram.sourceRevision)
        self.harmonized = try electrocardiogram.harmonize()
    }
}
