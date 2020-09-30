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
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let numberOfMeasurements: Int
    public let harmonized: HKElectrocardiogram.Harmonized

    public init(electrocardiogram: HKElectrocardiogram) throws {
        self.identifier = HealthKitType
            .electrocardiogramType
            .rawValue?
            .identifier ?? "HKElectrocardiogram"
        self.startTimestamp = electrocardiogram.startDate.timeIntervalSince1970
        self.endTimestamp = electrocardiogram.endDate.timeIntervalSince1970
        self.device = Device(device: electrocardiogram.device)
        self.numberOfMeasurements = electrocardiogram.numberOfVoltageMeasurements
        self.sourceRevision = SourceRevision(sourceRevision: electrocardiogram.sourceRevision)
        self.harmonized = try electrocardiogram.harmonize()
    }
}
