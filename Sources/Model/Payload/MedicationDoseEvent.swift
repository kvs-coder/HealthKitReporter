//
//  MedicationDoseEvent.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/**
 Logged medication dose. Read only.
 Schedule type follows **HKMedicationDoseEvent.ScheduleType** (1 as needed, 2 scheduled),
 log status **HKMedicationDoseEvent.LogStatus** (1 not interacted ... 6 not logged)
 */
@available(iOS 26.0, watchOS 26.0, *)
public struct MedicationDoseEvent: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let scheduleType: Int
        /// opaque identifier of the medication, see **UserAnnotatedMedication.Concept.identifier**
        public let medicationConceptIdentifier: String
        /// seconds since 1970
        public let scheduledTimestamp: Double?
        public let scheduledDoseQuantity: Double?
        public let doseQuantity: Double?
        public let logStatus: Int
        public let unit: String
        public let metadata: Metadata?

        public init(
            scheduleType: Int,
            medicationConceptIdentifier: String,
            scheduledTimestamp: Double?,
            scheduledDoseQuantity: Double?,
            doseQuantity: Double?,
            logStatus: Int,
            unit: String,
            metadata: Metadata?
        ) {
            self.scheduleType = scheduleType
            self.medicationConceptIdentifier = medicationConceptIdentifier
            self.scheduledTimestamp = scheduledTimestamp
            self.scheduledDoseQuantity = scheduledDoseQuantity
            self.doseQuantity = doseQuantity
            self.logStatus = logStatus
            self.unit = unit
            self.metadata = metadata
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

    init(doseEvent: HKMedicationDoseEvent) {
        self.uuid = doseEvent.uuid.uuidString
        self.identifier = doseEvent.sampleType.identifier
        self.startTimestamp = doseEvent.startDate.timeIntervalSince1970
        self.endTimestamp = doseEvent.endDate.timeIntervalSince1970
        self.device = Device(device: doseEvent.device)
        self.sourceRevision = SourceRevision(sourceRevision: doseEvent.sourceRevision)
        self.harmonized = Harmonized(
            scheduleType: doseEvent.scheduleType.rawValue,
            medicationConceptIdentifier: doseEvent.medicationConceptIdentifier.asArchivedString ?? String(),
            scheduledTimestamp: doseEvent.scheduledDate?.timeIntervalSince1970,
            scheduledDoseQuantity: doseEvent.scheduledDoseQuantity,
            doseQuantity: doseEvent.doseQuantity,
            logStatus: doseEvent.logStatus.rawValue,
            unit: doseEvent.unit.unitString,
            metadata: doseEvent.metadata?.asMetadata
        )
    }
}
// MARK: - Payload
@available(iOS 26.0, watchOS 26.0, *)
extension MedicationDoseEvent: Payload {
    public static func make(from dictionary: [String: Any]) throws -> MedicationDoseEvent {
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
        return MedicationDoseEvent(
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
@available(iOS 26.0, watchOS 26.0, *)
extension MedicationDoseEvent {
    static func collect(results: [HKSample]) -> [MedicationDoseEvent] {
        return results
            .compactMap { $0 as? HKMedicationDoseEvent }
            .map { MedicationDoseEvent(doseEvent: $0) }
    }
}
// MARK: - Harmonized: Payload
@available(iOS 26.0, watchOS 26.0, *)
extension MedicationDoseEvent.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> MedicationDoseEvent.Harmonized {
        guard
            let scheduleType = dictionary["scheduleType"] as? NSNumber,
            let medicationConceptIdentifier = dictionary["medicationConceptIdentifier"] as? String,
            let logStatus = dictionary["logStatus"] as? NSNumber,
            let unit = dictionary["unit"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let number: (String) -> Double? = { key in
            (dictionary[key] as? NSNumber).map { Double(truncating: $0) }
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return MedicationDoseEvent.Harmonized(
            scheduleType: scheduleType.intValue,
            medicationConceptIdentifier: medicationConceptIdentifier,
            scheduledTimestamp: number("scheduledTimestamp"),
            scheduledDoseQuantity: number("scheduledDoseQuantity"),
            doseQuantity: number("doseQuantity"),
            logStatus: logStatus.intValue,
            unit: unit,
            metadata: try metadata.map(Metadata.make)
        )
    }
}
