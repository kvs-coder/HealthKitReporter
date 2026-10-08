//
//  ClinicalRecord.swift
//  HealthKitReporter
//
//  Created by Quentin on 01.08.24.
//

#if os(iOS)
import HealthKit

/// **ClinicalRecord** a FHIR health record (iOS)
public struct ClinicalRecord: Identifiable, Sample {
    /// The value part of **ClinicalRecord**, with its metadata
    public struct Harmonized: Codable {
        public let displayName: String
        public let fhirSourceUrl: String?
        public let fhirVersion: String?
        public let fhirData: String?
        public let metadata: Metadata?
        
        /// Creates the **Harmonized** from its fields
        public init(
            displayName: String,
            fhirSourceUrl: String?,
            fhirVersion: String?,
            fhirData: String?,
            metadata: Metadata?
        ) {
            self.displayName = displayName
            self.fhirSourceUrl = fhirSourceUrl
            self.fhirVersion = fhirVersion
            self.fhirData = fhirData
            self.metadata = metadata
        }
        
        /// A copy with the given fields replaced; nil keeps the current value
        public func copyWith(
            displayName: String? = nil,
            fhirSourceUrl: String? = nil,
            fhirVersion: String? = nil,
            fhirData: String? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                displayName: displayName ?? self.displayName,
                fhirSourceUrl: fhirSourceUrl ?? self.fhirSourceUrl,
                fhirVersion: fhirVersion ?? self.fhirVersion,
                fhirData: fhirData ?? self.fhirData,
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
    
    init(clinicalRecord: HKClinicalRecord) throws {
        let fhirVersion: String? = clinicalRecord.fhirResource?.fhirVersion.stringRepresentation
        var fhirData: String? {
            guard let data: Data = clinicalRecord.fhirResource?.data,
                  let jsonString = String(data: data, encoding: .utf8) else {
                return nil
            }
            return jsonString
        }
        
        self.uuid = clinicalRecord.uuid.uuidString
        self.identifier = clinicalRecord.clinicalType.identifier
        self.startTimestamp = clinicalRecord.startDate.timeIntervalSince1970
        self.endTimestamp = clinicalRecord.endDate.timeIntervalSince1970
        self.device = Device(device: clinicalRecord.device)
        self.sourceRevision = SourceRevision(sourceRevision: clinicalRecord.sourceRevision)
        self.harmonized = Harmonized(
            displayName: clinicalRecord.displayName,
            fhirSourceUrl: clinicalRecord.fhirResource?.sourceURL?.absoluteString,
            fhirVersion: fhirVersion,
            fhirData: fhirData,
            metadata: clinicalRecord.metadata?.asMetadata
        )
    }
    
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
    
    /// A copy with the given fields replaced; nil keeps the current value, including the **uuid**
    public func copyWith(
        uuid: String? = nil,
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        harmonized: Harmonized? = nil
    ) -> ClinicalRecord {
        return ClinicalRecord(
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
extension ClinicalRecord: Payload {
    /**
     Makes a **ClinicalRecord** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> ClinicalRecord {
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
        return ClinicalRecord(
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
// MARK: - Factory
extension ClinicalRecord {
    static func collect(results: [HKSample]) -> [ClinicalRecord] {
        var samples = [ClinicalRecord]()
        if let clinicalRecords = results as? [HKClinicalRecord] {
            for clinicalRecord in clinicalRecords {
                do {
                    let sample = try ClinicalRecord(
                        clinicalRecord: clinicalRecord
                    )
                    samples.append(sample)
                } catch {
                    continue
                }
            }
        }
        return samples
    }
}
// MARK: - Payload
extension ClinicalRecord.Harmonized: Payload {
    /**
     Makes a **ClinicalRecord.Harmonized** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> ClinicalRecord.Harmonized {
        guard
            let displayName = dictionary["displayName"] as? String,
            let fhirSourceUrl = dictionary["fhirSourceUrl"] as? String?,
            let fhirVersion = dictionary["fhirVersion"] as? String?,
            let fhirData = dictionary["fhirData"] as? String?
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return ClinicalRecord.Harmonized(
            displayName: displayName,
            fhirSourceUrl: fhirSourceUrl,
            fhirVersion: fhirVersion,
            fhirData: fhirData,
            metadata: try metadata.map(Metadata.make)
        )
    }
}
#endif
