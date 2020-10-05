//
//  QuantitySampleRetriever.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation
import HealthKit

class QuantitySampleRetriever {
    typealias QuantityResultsHandler = (
        _ query: HKSampleQuery,
        _ samples: [Quantity],
        _ error: Error?
    ) -> Void

    public func sampleQuery(
        healthStore: HKHealthStore,
        quantityType: HKQuantityType,
        unit: HKUnit,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        resultsHandler: @escaping QuantityResultsHandler
    ) {
        let query = HKSampleQuery(
            sampleType: quantityType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (query, data, error) in
            guard
                error == nil,
                let result = data
            else {
                resultsHandler(
                    query,
                    [],
                    error
                )
                return
            }
            var samples = [Quantity]()
            for element in result {
                if let quantitySample = element as? HKQuantitySample {
                    do {
                        let sample = try Quantity(
                            quantitySample: quantitySample,
                            unit: unit
                        )
                        samples.append(sample)
                    } catch {
                        continue
                    }
                }
            }
            resultsHandler(
                query,
                samples,
                nil
            )
        }
        healthStore.execute(query)
    }
}
