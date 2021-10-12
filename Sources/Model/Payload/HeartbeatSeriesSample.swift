//
//  HeartbeatSeriesSample.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 12.10.21.
//

import Foundation
import HealthKit

@available(iOS 13.0, *)
public struct HeartbeatSeriesSample: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let count: Int
        public let series: [HeartbeatSeries]
        public let metadata: [String: String]?

        public init(
            count: Int,
            series: [HeartbeatSeries],
            metadata: [String: String]?
        ) {
            self.count = count
            self.series = series
            self.metadata = metadata
        }

        public func copyWith(
            count: Int? = nil,
            series: [HeartbeatSeries]? = nil,
            metadata: [String: String]? = nil
        ) -> Harmonized {
            return Harmonized(
                count: count ?? self.count,
                series: series ?? self.series,
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
    init(seriesSample: HKHeartbeatSeriesSample, series: [HeartbeatSeries]) {
        self.uuid = seriesSample.uuid.uuidString
        self.identifier = seriesSample.sampleType.identifier
        self.startTimestamp = seriesSample.startDate.timeIntervalSince1970
        self.endTimestamp = seriesSample.endDate.timeIntervalSince1970
        self.device = Device(device: seriesSample.device)
        self.sourceRevision = SourceRevision(sourceRevision: seriesSample.sourceRevision)
        self.harmonized = seriesSample.harmonize(series: series)
    }
}
