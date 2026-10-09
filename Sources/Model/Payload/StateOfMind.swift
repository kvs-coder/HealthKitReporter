//
//  StateOfMind.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/**
 Logged emotion or mood.
 Raw values follow **HKStateOfMind**: kind 1 momentary emotion, 2 daily mood;
 valence classification 1 very unpleasant ... 7 very pleasant; labels and associations their enum raw values
 */
@available(iOS 18.0, watchOS 11.0, *)
public struct StateOfMind: Identifiable, Sample {
    /// The value part of **StateOfMind**, with its metadata
    public struct Harmonized: Codable {
        public let kind: Int
        /// -1 very unpleasant ... 1 very pleasant
        public let valence: Double
        /// read only, derived from the valence
        public let valenceClassification: Int?
        public let labels: [Int]
        public let associations: [Int]
        public let metadata: Metadata?

        /// Creates the **Harmonized** from its fields
        public init(
            kind: Int,
            valence: Double,
            valenceClassification: Int?,
            labels: [Int],
            associations: [Int],
            metadata: Metadata?
        ) {
            self.kind = kind
            self.valence = valence
            self.valenceClassification = valenceClassification
            self.labels = labels
            self.associations = associations
            self.metadata = metadata
        }

        /// A copy with the given fields replaced; nil keeps the current value
        public func copyWith(
            kind: Int? = nil,
            valence: Double? = nil,
            valenceClassification: Int? = nil,
            labels: [Int]? = nil,
            associations: [Int]? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                kind: kind ?? self.kind,
                valence: valence ?? self.valence,
                valenceClassification: valenceClassification ?? self.valenceClassification,
                labels: labels ?? self.labels,
                associations: associations ?? self.associations,
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

    /**
     Creates the payload. **uuid** names the stored sample; a new one by default,
     since HealthKit gives every saved sample its own
     */
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

    init(stateOfMind: HKStateOfMind) {
        self.uuid = stateOfMind.uuid.uuidString
        self.identifier = stateOfMind.sampleType.identifier
        self.startTimestamp = stateOfMind.startDate.timeIntervalSince1970
        self.endTimestamp = stateOfMind.endDate.timeIntervalSince1970
        self.device = Device(device: stateOfMind.device)
        self.sourceRevision = SourceRevision(sourceRevision: stateOfMind.sourceRevision)
        self.harmonized = Harmonized(
            kind: stateOfMind.kind.rawValue,
            valence: stateOfMind.valence,
            valenceClassification: stateOfMind.valenceClassification.rawValue,
            labels: stateOfMind.labels.map(\.rawValue),
            associations: stateOfMind.associations.map(\.rawValue),
            metadata: stateOfMind.metadata?.asMetadata
        )
    }

    /// A copy with the given fields replaced; nil keeps the current value, including the **uuid**
    public func copyWith(
        uuid: String? = nil,
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        harmonized: Harmonized? = nil
    ) -> StateOfMind {
        return StateOfMind(
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
@available(iOS 18.0, watchOS 11.0, *)
extension StateOfMind: Original {
    /// HealthKit rejects a valence outside -1...1 and unknown kinds, labels or associations
    func asOriginal() throws -> HKStateOfMind {
        try startTimestamp.checkInterval(to: endTimestamp)
        guard
            (1...2).contains(harmonized.kind),
            (-1...1).contains(harmonized.valence),
            harmonized.labels.allSatisfy({ (1...38).contains($0) }),
            harmonized.associations.allSatisfy({ (1...18).contains($0) }),
            let kind = HKStateOfMind.Kind(rawValue: harmonized.kind)
        else {
            throw HealthKitError.invalidValue("Invalid state of mind: \(harmonized)")
        }
        return HKStateOfMind(
            date: startTimestamp.asDate,
            kind: kind,
            valence: harmonized.valence,
            labels: harmonized.labels.compactMap { HKStateOfMind.Label(rawValue: $0) },
            associations: harmonized.associations.compactMap { HKStateOfMind.Association(rawValue: $0) },
            metadata: try harmonized.metadata?.asOriginal()
        )
    }
}
// MARK: - Payload
@available(iOS 18.0, watchOS 11.0, *)
extension StateOfMind: Payload {
    /**
     Makes a **StateOfMind** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> StateOfMind {
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
        return StateOfMind(
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
@available(iOS 18.0, watchOS 11.0, *)
extension StateOfMind {
    static func collect(results: [HKSample]) throws -> [StateOfMind] {
        return try results.converted { (sample: HKStateOfMind) in
            StateOfMind(stateOfMind: sample)
        }
    }
}
// MARK: - Harmonized: Payload
@available(iOS 18.0, watchOS 11.0, *)
extension StateOfMind.Harmonized: Payload {
    /**
     Makes a **StateOfMind.Harmonized** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> StateOfMind.Harmonized {
        guard
            let kind = dictionary["kind"] as? NSNumber,
            let valence = dictionary["valence"] as? NSNumber,
            let labels = dictionary["labels"] as? [NSNumber],
            let associations = dictionary["associations"] as? [NSNumber]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return StateOfMind.Harmonized(
            kind: kind.intValue,
            valence: Double(truncating: valence),
            valenceClassification: (dictionary["valenceClassification"] as? NSNumber)?.intValue,
            labels: labels.map(\.intValue),
            associations: associations.map(\.intValue),
            metadata: try metadata.map(Metadata.make)
        )
    }
}
