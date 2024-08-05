//
//  ClinicalRecord.swift
//  HealthKitReporter
//
//  Created by Quentin on 01.08.24.
//

import HealthKit

@available(iOS 12.0, *)
public struct ClinicalRecord: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let displayName: String
        public let fhirSourceUrl: String?
        public let fhirVersion: String?
        public let fhirData: String?
        public let metadata: Metadata?
        
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
        let fhirVersion: String? = if #available(iOS 14.0, *) {
            clinicalRecord.fhirResource?.fhirVersion.stringRepresentation
        } else {
            nil
        }
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
    
    public func copyWith(
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        harmonized: Harmonized? = nil
    ) -> ClinicalRecord {
        return ClinicalRecord(
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
@available(iOS 12.0, *)
extension ClinicalRecord: Payload {
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
    public static func collect(from array: [Any]) throws -> [ClinicalRecord] {
        var results = [ClinicalRecord]()
        for element in array {
            if let dictionary = element as? [String: Any] {
                let harmonized = try ClinicalRecord.make(from: dictionary)
                results.append(harmonized)
            }
        }
        return results
    }
}
// MARK: - Factory
@available(iOS 12.0, *)
extension ClinicalRecord {
    public static func collect(results: [HKSample]) -> [ClinicalRecord] {
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
@available(iOS 12.0, *)
extension ClinicalRecord.Harmonized: Payload {
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
            metadata: metadata?.asMetadata
        )
    }
}
