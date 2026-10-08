//
//  Extensions+HKClinicalRecord.swift
//  HealthKitReporter
//
//  Created by Quentin on 01.08.24.
//

import HealthKit

extension HKClinicalRecord: Harmonizable {
    typealias Harmonized = ClinicalRecord.Harmonized
    
    func harmonize() throws -> Harmonized {
        let fhirVersion: String? = fhirResource?.fhirVersion.stringRepresentation
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
