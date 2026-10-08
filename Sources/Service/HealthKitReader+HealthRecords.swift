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
    @available(iOS 16.0, *)
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
    ) throws -> SampleQuery {
        let type = VisionPrescriptionType.visionPrescription
        guard let sampleType = type.original as? HKSampleType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKSampleType")
        }
        return HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (_, data, error) in
            guard
                error == nil,
                let results = data
            else {
                resultsHandler([], error)
                return
            }
            resultsHandler(VisionPrescription.collect(results: results), nil)
        }
    }
}
