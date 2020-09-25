//
//  Electrocardiogram.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

@available(iOS 14.0, *)
public struct Electrocardiogram: Sample {
    public let identifier: String
    public let startDate: String
    public let endDate: String
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let numberOfMeasurements: Int
    public let harmonized: HKElectrocardiogram.Harmonized

    public init(electrocardiogram: HKElectrocardiogram) throws {
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
