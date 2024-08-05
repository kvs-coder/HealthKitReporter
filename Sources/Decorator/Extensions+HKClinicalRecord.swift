//
//  Extensions+HKClinicalRecord.swift
//  HealthKitReporter
//
//  Created by Quentin on 01.08.24.
//

import HealthKit

@available(iOS 12.0, *)
extension HKClinicalRecord: Harmonizable {
    typealias Harmonized = ClinicalRecord.Harmonized
    
    func harmonize() throws -> Harmonized {
        let fhirVersion: String? = if #available(iOS 14.0, *) {
            fhirResource?.fhirVersion.stringRepresentation
        } else {
            nil
        }
        var fhirData: String? {
            guard let data: Data = fhirResource?.data,
                  let jsonString = String(data: data, encoding: .utf8) else {
                return nil
            }
            return jsonString
        }
        
        return Harmonized(
            displayName: displayName,
            fhirSourceUrl: fhirResource?.sourceURL?.absoluteString,
            fhirVersion: fhirVersion,
            fhirData: fhirData,
            metadata: metadata?.asMetadata
        )
    }
}
