//
//  HeartbeatSeries.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 12.10.21.
//

import HealthKit

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
        public let metadata: Metadata?

        public init(
            count: Int,
            measurements: [Measurement],
            metadata: Metadata?
        ) {
            self.count = count
            self.measurements = measurements
            self.metadata = metadata
        }

        public func copyWith(
            count: Int? = nil,
            measurements: [Measurement]? = nil,
            metadata: Metadata? = nil
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
        uuid: String = UUID().uuidString,
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        device: Device?,
        sourceRevision: SourceRevision,
        harmonized: Harmonized
    ) {
        self.uuid = uuid
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

    public func copyWith(
        uuid: String? = nil,
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        harmonized: Harmonized? = nil
    ) -> HeartbeatSeries {
        return HeartbeatSeries(
            uuid: uuid ?? self.uuid,
            identifier: identifier ?? self.identifier,
            startTimestamp: startTimestamp ?? self.startTimestamp,
            endTimestamp: endTimestamp ?? self.endTimestamp,
            device: device ?? self.device,
            sourceRevision: sourceRevision ?? self.sourceRevision,
            harmonized: harmonized ?? self.harmonized
        )
    }
}
// MARK: - Payload
extension HeartbeatSeries: Payload {
    public static func make(from dictionary: [String: Any]) throws -> HeartbeatSeries {
        guard
            let identifier = dictionary["identifier"] as? String,
            let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
            let endTimestamp = dictionary["endTimestamp"] as? NSNumber,
            let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let device = dictionary["device"] as? [String: Any]
        return HeartbeatSeries(
            uuid: dictionary.payloadUUID,
            identifier: identifier,
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: Double(truncating: endTimestamp),
            device: device != nil
                ? try Device.make(from: device!)
                : nil,
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
// MARK: - Payload
extension HeartbeatSeries.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> HeartbeatSeries.Harmonized {
        guard
            let count = dictionary.int("count"),
            let measurements = dictionary["measurements"] as? [Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return HeartbeatSeries.Harmonized(
            count: count,
            measurements: try HeartbeatSeries.Measurement.collect(from: measurements),
            metadata: try metadata.map(Metadata.make)
        )
    }
}
// MARK: - Payload
extension HeartbeatSeries.Measurement: Payload {
    public static func make(from dictionary: [String: Any]) throws -> HeartbeatSeries.Measurement {
        guard
            let timeSinceSeriesStart = dictionary["timeSinceSeriesStart"] as? NSNumber,
            let precededByGap = dictionary.bool("precededByGap"),
            let done = dictionary.bool("done")
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return HeartbeatSeries.Measurement(
            timeSinceSeriesStart: Double(truncating: timeSinceSeriesStart),
            precededByGap: precededByGap,
            done: done
        )
    }
}
