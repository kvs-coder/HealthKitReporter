//
//  ElectrocardiogramRetriever.swift
//  HealthKitReporter
//
//  Created by Victor on 21.10.20.
//

import Foundation
import HealthKit

@available(iOS 14.0, *)
class ElectrocardiogramRetriever {
    func makeElectrocardiogramQuery(
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

    func electrocardiogramVoltageMeasurementQuery(
        healthStore: HKHealthStore,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        dataHandler: @escaping ElectrocardiogramVoltageMeasurementDataHandler
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
                let results = data as? [HKElectrocardiogram]
            else {
                dataHandler(
                    nil,
                    false,
                    error
                )
                return
            }
            for ecgSample in results {
                let voltageQuery = HKElectrocardiogramQuery(ecgSample) { (query, result) in
                    switch(result) {
                    case .measurement(let voltageMeasurement):
                        do {
                            let value = try Electrocardiogram.VoltageMeasurement(
                                voltageMeasurement: voltageMeasurement
                            )
                            dataHandler(
                                value,
                                false,
                                nil
                            )
                        } catch {
                            dataHandler(
                                nil,
                                false,
                                nil
                            )
                        }
                    case .done:
                        dataHandler(
                            nil,
                            true,
                            nil
                        )
                    case .error(let error):
                        dataHandler(
                            nil,
                            false,
                            error
                        )
                    @unknown default:
                        dataHandler(
                            nil,
                            false,
                            HealthKitError.notAvailable(
                                "Unknown case of Electrocardiogram.VoltageMeasurement result"
                            )
                        )
                    }
                }
                healthStore.execute(voltageQuery)
            }
        }
        return query
    }
}
