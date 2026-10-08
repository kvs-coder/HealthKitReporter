//
//  HealthKitReader+HealthRecords.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

// MARK: - HealthRecords
extension HealthKitReader {
    /**
     Queries vision prescriptions.
     - Requires: per-object read authorization, see **HealthKitManager.requestPerObjectReadAuthorization**
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with vision prescriptions
     - Throws: HealthKitError.invalidType
     */
    @available(iOS 16.0, watchOS 9.0, *)
    public func visionPrescriptionQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping VisionPrescriptionResultsHandler
    ) throws -> QueryHandle {
        return try typedSampleQuery(
            type: VisionPrescriptionType.visionPrescription,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            collect: VisionPrescription.collect,
            resultsHandler: resultsHandler
        )
    }
    #if os(iOS)
    /**
     Queries clinical records of one type.
     - Requires: the Clinical Health Records entitlement and **HealthKitManager.supportsHealthRecords**
     - Parameter type: **ClinicalType** type
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with clinical records
     - Throws: HealthKitError.invalidType
     */
    public func clinicalRecordQuery(
        type: ClinicalType,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping ClinicalRecordResultsHandler
    ) throws -> QueryHandle {
        return try typedSampleQuery(
            type: type,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            collect: ClinicalRecord.collect,
            resultsHandler: resultsHandler
        )
    }
    /**
     Queries verifiable clinical records, such as SMART Health Cards.
     The system asks the user which records to share each time the query runs.
     - Parameter recordTypes: **String** record types, e.g. "https://smarthealth.cards#immunization"
     - Parameter sourceTypes: **String** source types (optional, iOS 15.4+), e.g. "https://smarthealth.cards".
     All sources by default
     - Parameter predicate: **NSPredicate** predicate (optional). nil by default
     - Parameter resultsHandler: returns a block with verifiable clinical records
     */
    public func verifiableClinicalRecordQuery(
        recordTypes: [String],
        sourceTypes: [String] = [],
        predicate: NSPredicate? = nil,
        resultsHandler: @escaping VerifiableClinicalRecordResultsHandler
    ) -> QueryHandle {
        func handler(
            _: HKVerifiableClinicalRecordQuery,
            records: [HKVerifiableClinicalRecord]?,
            error: Error?
        ) {
            guard error == nil, let records = records else {
                resultsHandler([], error)
                return
            }
            resultsHandler(VerifiableClinicalRecord.collect(results: records), nil)
        }
        guard !sourceTypes.isEmpty, #available(iOS 15.4, *) else {
            return QueryHandle(
                HKVerifiableClinicalRecordQuery(
                    recordTypes: recordTypes,
                    predicate: predicate,
                    resultsHandler: handler
                )
            )
        }
        return QueryHandle(HKVerifiableClinicalRecordQuery(
            recordTypes: recordTypes,
            sourceTypes: sourceTypes.map { HKVerifiableClinicalRecordSourceType(rawValue: $0) },
            predicate: predicate,
            resultsHandler: handler
        ))
    }
    /**
     Queries CDA documents. The handler is called once per batch until **done** is true.
     The user authorizes each document the first time it matches.
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter includeDocumentData: **Bool** include the CDA XML. True by default
     - Parameter resultsHandler: returns a block with CDA documents
     - Throws: HealthKitError.invalidType
     */
    public func cdaDocumentQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        includeDocumentData: Bool = true,
        resultsHandler: @escaping CDADocumentResultsHandler
    ) throws -> QueryHandle {
        let type = DocumentType.cda
        guard let documentType = type.hkObjectType as? HKDocumentType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKDocumentType")
        }
        return QueryHandle(HKDocumentQuery(
            documentType: documentType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors,
            includeDocumentData: includeDocumentData
        ) { (_, samples, done, error) in
            guard error == nil, let samples = samples else {
                resultsHandler([], true, error)
                return
            }
            resultsHandler(CDADocument.collect(results: samples), done, nil)
        })
    }
    #endif
}
