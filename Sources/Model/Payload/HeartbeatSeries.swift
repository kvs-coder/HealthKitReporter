//
//  HeartbeatSeries.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 12.10.21.
//

import Foundation
import HealthKit

@available(iOS 13.0, *)
public struct HeartbeatSeries: Identifiable, Sample {
    public struct Measurement: Codable {
        public let timeSinceSeriesStart: Double
        public let precededByGap: Bool
        public let done: Bool
        public init(
            timeSinceSeriesStart: Double,
            precededByGap: Bool,
            done: Bool
        ) {
            self.timeSinceSeriesStart = timeSinceSeriesStart
            self.precededByGap = precededByGap
            self.done = done
        }
    }

    public struct Harmonized: Codable {
        public let count: Int
        public let measurements: [Measurement]
        public let metadata: [String: String]?

        public init(
            count: Int,
            measurements: [Measurement],
            metadata: [String: String]?
        ) {
            self.count = count
            self.measurements = measurements
            self.metadata = metadata
        }

        public func copyWith(
            count: Int? = nil,
            measurements: [Measurement]? = nil,
            metadata: [String: String]? = nil
        ) -> Harmonized {
            return Harmonized(
                count: count ?? self.count,
                measurements: measurements ?? self.measurements,
                metadata: metadata ?? self.metadata
            )
        }
    }

    public let uuid: String
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: Harmonized
    
    public init(
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        device: Device?,
        sourceRevision: SourceRevision,
        harmonized: Harmonized
    ) {
        self.uuid = UUID().uuidString
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.harmonized = harmonized
    }
    init(sample: HKHeartbeatSeriesSample, measurements: [Measurement]) {
        self.uuid = sample.uuid.uuidString
        self.identifier = sample.sampleType.identifier
        self.startTimestamp = sample.startDate.timeIntervalSince1970
        self.endTimestamp = sample.endDate.timeIntervalSince1970
        self.device = Device(device: sample.device)
        self.sourceRevision = SourceRevision(sourceRevision: sample.sourceRevision)
        self.harmonized = sample.harmonize(measurements: measurements)
    }
}
