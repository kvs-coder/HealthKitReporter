//
//  ElectrocardiogramRetriever.swift
//  HealthKitReporter
//
//  Created by Florian on 21.10.20.
//

import Foundation
import HealthKit

@available(iOS 14.0, *)
class ElectrocardiogramRetriever {
    func makeSampleQuery(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        resultsHandler: @escaping ElectrocardiogramResultsHandler
    ) throws -> HKSampleQuery {
        let electrocardiogramType = ElectrocardiogramType.electrocardiogramType
        guard
            let type = electrocardiogramType.original as? HKElectrocardiogramType
        else {
            throw HealthKitError.invalidType(
                "\(electrocardiogramType) can not be represented as HKElectrocardiogramType"
            )
        }
        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (query, data, error) in
            guard
                error == nil,
                let results = data
            else {
                resultsHandler([], error)
                return
            }
            let samples = Electrocardiogram.collect(
                results: results
            )
            resultsHandler(samples, nil)
        }
        return query
    }

    func makeAnchoredObjectQuery(
        predicate: NSPredicate?,
        anchor: HKQueryAnchor?,
        limit: Int,
        monitorUpdates: Bool,
        completionHandler: @escaping ElectrocardiogramResultsHandler
    ) throws -> HKAnchoredObjectQuery {
        let electrocardiogramType = ElectrocardiogramType.electrocardiogramType
        guard
            let type = electrocardiogramType.original as? HKElectrocardiogramType
        else {
            throw HealthKitError.invalidType(
                "\(electrocardiogramType) can not be represented as HKElectrocardiogramType"
            )
        }
        let resultsHandler: AnchoredObjectQueryHandler = { (_, data, deletedObjects, anchor, error) in
            guard
                error == nil,
                let results = data
            else {
                completionHandler([], error)
                return
            }
            let samples = Electrocardiogram.collect(
                results: results
            )
            completionHandler(samples, nil)
        }
        let query = HKAnchoredObjectQuery(
            type: type,
            predicate: predicate,
            anchor: anchor,
            limit: limit,
            resultsHandler: resultsHandler
        )
        if monitorUpdates {
            query.updateHandler = resultsHandler
        }
        return query
    }
}
