//
//  Audiogram.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// Hearing test result. Frequencies are in hertz (Hz), sensitivities in decibel hearing level (dBHL)
public struct Audiogram: Identifiable, Sample {
    /// One test at a frequency (iOS 18.1+)
    public struct Test: Codable {
        /// dBHL
        public let sensitivity: Double
        /// 0 air conduction (**HKAudiogramConductionType**)
        public let conductionType: Int
        public let masked: Bool
        /// 0 left, 1 right (**HKAudiogramSensitivityTestSide**)
        public let side: Int

        public init(sensitivity: Double, conductionType: Int, masked: Bool, side: Int) {
            self.sensitivity = sensitivity
            self.conductionType = conductionType
            self.masked = masked
            self.side = side
        }
    }

    public struct SensitivityPoint: Codable {
        /// Hz
        public let frequency: Double
        /// dBHL
        public let leftEarSensitivity: Double?
        /// dBHL
        public let rightEarSensitivity: Double?
        /// tests behind the sensitivities (iOS 18.1+, read only)
        public let tests: [Test]?

        public init(
            frequency: Double,
            leftEarSensitivity: Double?,
            rightEarSensitivity: Double?,
            tests: [Test]? = nil
        ) {
            self.frequency = frequency
            self.leftEarSensitivity = leftEarSensitivity
            self.rightEarSensitivity = rightEarSensitivity
            self.tests = tests
        }
    }

    public struct Harmonized: Codable {
        public let sensitivityPoints: [SensitivityPoint]
        public let metadata: Metadata?

        public init(sensitivityPoints: [SensitivityPoint], metadata: Metadata?) {
            self.sensitivityPoints = sensitivityPoints
            self.metadata = metadata
        }

        public func copyWith(
            sensitivityPoints: [SensitivityPoint]? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                sensitivityPoints: sensitivityPoints ?? self.sensitivityPoints,
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

    init(audiogramSample: HKAudiogramSample) throws {
        self.uuid = audiogramSample.uuid.uuidString
        self.identifier = audiogramSample.sampleType.identifier
        self.startTimestamp = audiogramSample.startDate.timeIntervalSince1970
        self.endTimestamp = audiogramSample.endDate.timeIntervalSince1970
        self.device = Device(device: audiogramSample.device)
        self.sourceRevision = SourceRevision(sourceRevision: audiogramSample.sourceRevision)
        self.harmonized = try audiogramSample.harmonize()
    }

    public func copyWith(
        uuid: String? = nil,
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        harmonized: Harmonized? = nil
    ) -> Audiogram {
        return Audiogram(
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
// MARK: - Original
extension Audiogram: Original {
    /// HealthKit accepts at most 30 points with unique, ascending frequencies
    func asOriginal() throws -> HKAudiogramSample {
        try startTimestamp.checkInterval(to: endTimestamp)
        let frequencies = harmonized.sensitivityPoints.map(\.frequency)
        guard
            !frequencies.isEmpty,
            frequencies.count <= 30,
            zip(frequencies, frequencies.dropFirst()).allSatisfy({ $0 < $1 })
        else {
            throw HealthKitError.invalidValue(
                "Audiogram needs 1 to 30 points with unique, ascending frequencies: \(frequencies)"
            )
        }
        let decibel = HKUnit.decibelHearingLevel()
        let points = try harmonized.sensitivityPoints.map { point in
            try HKAudiogramSensitivityPoint(
                frequency: HKQuantity(unit: .hertz(), doubleValue: point.frequency),
                leftEarSensitivity: point.leftEarSensitivity.map {
                    HKQuantity(unit: decibel, doubleValue: $0)
                },
                rightEarSensitivity: point.rightEarSensitivity.map {
                    HKQuantity(unit: decibel, doubleValue: $0)
                }
            )
        }
        return HKAudiogramSample(
            sensitivityPoints: points,
            start: startTimestamp.asDate,
            end: endTimestamp.asDate,
            metadata: try harmonized.metadata?.asOriginal()
        )
    }
}
// MARK: - Payload
extension Audiogram: Payload {
    public static func make(from dictionary: [String: Any]) throws -> Audiogram {
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
        return Audiogram(
            uuid: dictionary.payloadUUID,
            identifier: identifier,
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: Double(truncating: endTimestamp),
            device: try device.map(Device.make),
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
// MARK: - Factory
extension Audiogram {
    static func collect(results: [HKSample]) -> [Audiogram] {
        return results
            .compactMap { $0 as? HKAudiogramSample }
            .compactMap { try? Audiogram(audiogramSample: $0) }
    }
}
// MARK: - Harmonized: Payload
extension Audiogram.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> Audiogram.Harmonized {
        guard let sensitivityPoints = dictionary["sensitivityPoints"] as? [[String: Any]] else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return Audiogram.Harmonized(
            sensitivityPoints: try sensitivityPoints.map(Audiogram.SensitivityPoint.make),
            metadata: try metadata.map(Metadata.make)
        )
    }
}
// MARK: - SensitivityPoint: Payload
extension Audiogram.SensitivityPoint: Payload {
    public static func make(from dictionary: [String: Any]) throws -> Audiogram.SensitivityPoint {
        guard let frequency = dictionary["frequency"] as? NSNumber else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let number: (String) -> Double? = { key in
            (dictionary[key] as? NSNumber).map { Double(truncating: $0) }
        }
        return Audiogram.SensitivityPoint(
            frequency: Double(truncating: frequency),
            leftEarSensitivity: number("leftEarSensitivity"),
            rightEarSensitivity: number("rightEarSensitivity")
        )
    }
}
