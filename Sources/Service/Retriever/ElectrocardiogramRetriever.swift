//
//  ElectrocardiogramRetriever.swift
//  HealthKitReporter
//
//  Created by Victor on 21.10.20.
//

import HealthKit

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
            let type = electrocardiogramType.hkObjectType as? HKElectrocardiogramType
        else {
            throw HealthKitError.invalidType(
                "\(electrocardiogramType) can not be represented as HKElectrocardiogramType"
            )
        }
        return HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (_, data, error) in
            guard
                error == nil,
                let results = data as? [HKElectrocardiogram]
            else {
                resultsHandler([], error)
                return
            }
            guard withVoltageMeasurements else {
                resultsHandler(Electrocardiogram.collect(results: results), nil)
                return
            }
            let collector = SampleResultsCollector<Electrocardiogram>(
                label: "HealthKitReporter.ElectrocardiogramRetriever",
                count: results.count
            )
            for (index, sample) in results.enumerated() {
                collector.enter()
                healthStore.execute(
                    self.makeVoltageQuery(for: sample, at: index, collector: collector)
                )
            }
            collector.notify(resultsHandler)
        }
    }

    private func makeVoltageQuery(
        for sample: HKElectrocardiogram,
        at index: Int,
        collector: SampleResultsCollector<Electrocardiogram>
    ) -> HKElectrocardiogramQuery {
        var measurements = [Electrocardiogram.VoltageMeasurement]()
        return HKElectrocardiogramQuery(sample) { (_, result) in
            switch result {
            case .measurement(let voltageMeasurement):
                if let measurement = try? Electrocardiogram.VoltageMeasurement(
                    voltageMeasurement: voltageMeasurement
                ) {
                    measurements.append(measurement)
                }
            case .done:
                collector.finish(
                    index,
                    with: try? Electrocardiogram(
                        electrocardiogram: sample,
                        voltageMeasurements: measurements
                    )
                )
            case .error(let error):
                collector.fail(index, with: error)
            @unknown default:
                collector.fail(
                    index,
                    with: HealthKitError.notAvailable(
                        "Unknown case of Electrocardiogram.VoltageMeasurement result"
                    )
                )
            }
        }
    }
}
