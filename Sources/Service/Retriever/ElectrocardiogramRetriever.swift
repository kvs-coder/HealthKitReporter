//
//  ElectrocardiogramRetriever.swift
//  HealthKitReporter
//
//  Created by Victor on 21.10.20.
//

import HealthKit

@available(iOS 14.0, *)
class ElectrocardiogramRetriever {
    func makeElectrocardiogramQuery(
        healthStore: HKHealthStore,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        withVoltageMeasurements: Bool,
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
                let results = data as? [HKElectrocardiogram]
            else {
                resultsHandler([], error)
                return
            }
            var ecgs: [Electrocardiogram]
            switch withVoltageMeasurements {
            case true:
                ecgs = []
                var ecgsError: Error?
                let group = DispatchGroup()
                for ecgSample in results {
                    var measurments = [Electrocardiogram.VoltageMeasurement]()
                    group.enter()
                    let voltageQuery = HKElectrocardiogramQuery(ecgSample) { (query, result) in
                        switch(result) {
                        case .measurement(let voltageMeasurement):
                            if let measurment = try? Electrocardiogram.VoltageMeasurement(voltageMeasurement: voltageMeasurement) {
                                measurments.append(measurment)
                            }
                        case .done:
                            if let ecg = try? Electrocardiogram(electrocardiogram: ecgSample, voltageMeasurements: measurments) {
                                ecgs.append(ecg)
                            }
                            group.leave()
                        case .error(let error):
                            ecgsError = error
                            group.leave()
                        @unknown default:
                            ecgsError = HealthKitError.notAvailable("Unknown case of Electrocardiogram.VoltageMeasurement result")
                            group.leave()
                        }
                    }
                    healthStore.execute(voltageQuery)
                }
                group.notify(queue: .global()) {
                    resultsHandler(ecgs, ecgsError)
                }
            case false:
                ecgs = Electrocardiogram.collect(results: results)
                resultsHandler(ecgs, nil)
            }
        }
        return query
    }
}
