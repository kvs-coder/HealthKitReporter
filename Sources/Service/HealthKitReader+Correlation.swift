//
//  HealthKitReader+Correlation.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

// MARK: - Correlation
extension HealthKitReader {
    /**
     Queries correlations.
     - Parameter type: **CorrelationType** types
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func correlationQuery(
        type: CorrelationType,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping CorrelationResultsHandler
    ) throws -> SampleQuery {
        guard let correlationType = type.original as? HKCorrelationType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKWorkoutType"
            )
        }
        let query = HKSampleQuery(
            sampleType: correlationType,
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
            let samples = Correlation.collect(
                results: results
            )
            resultsHandler(samples, nil)
        }
        return query
    }
    /**
     Queries correlation.
     - Parameter type: **CorrelationType** type
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter typePredicates: type predicates (optional). Key is the type
     identifier **String**  and value is **NSPredicate**. Nil by default
     - Parameter completionHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func correlationQuery(
        type: CorrelationType,
        predicate: NSPredicate? = .allSamples,
        typePredicates: [String: NSPredicate]? = nil,
        completionHandler: @escaping CorrelationCompletionHandler
    ) throws -> CorrelationQuery {
        guard let correlationType = type.original as? HKCorrelationType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKCorrelationType"
            )
        }
        let query = HKCorrelationQuery(
            type: correlationType,
            predicate: predicate,
            samplePredicates: typePredicates?.sampleTypePredicates
        ) { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler([], error)
                return
            }
            var correlations = [Correlation]()
            for element in result {
                do {
                    let correlation = try Correlation(correlation: element)
                    correlations.append(correlation)
                } catch {
                    continue
                }
            }
            completionHandler(correlations, nil)
        }
        return query
    }
}
