//
//  ElectrocardiogramRetriever.swift
//  HealthKitReporter
//
//  Created by Victor on 21.10.20.
//

import HealthKit

class ElectrocardiogramRetriever {
    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    func makeElectrocardiogramQuery(
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
            guard error == nil, let data = data else {
                resultsHandler([], error)
                return
            }
            guard let results = data as? [HKElectrocardiogram] else {
                resultsHandler([], HealthKitError.invalidType("Samples \(data) are not HKElectrocardiogram"))
                return
            }
            guard withVoltageMeasurements else {
                do {
                    resultsHandler(try Electrocardiogram.collect(results: results), nil)
                } catch {
                    resultsHandler([], error)
                }
                return
            }
            let collector = SampleResultsCollector<Electrocardiogram>(
                label: "HealthKitReporter.ElectrocardiogramRetriever",
                count: results.count
            )
            for (index, sample) in results.enumerated() {
                collector.enter()
                self.healthStore.execute(
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
        var conversionError: Error?
        return HKElectrocardiogramQuery(sample) { (_, result) in
            switch result {
            case .measurement(let voltageMeasurement):
                guard conversionError == nil else {
                    return
                }
                do {
                    measurements.append(
                        try Electrocardiogram.VoltageMeasurement(voltageMeasurement: voltageMeasurement)
                    )
                } catch {
                    conversionError = HealthKitError.parsingFailed(
                        "Voltage measurement of \(sample.parsingName) could not be parsed: \(error)"
                    )
                }
            case .done:
                if let conversionError = conversionError {
                    collector.fail(index, with: conversionError)
                    return
                }
                do {
                    collector.finish(
                        index,
                        with: try Electrocardiogram(
                            electrocardiogram: sample,
                            voltageMeasurements: measurements
                        )
                    )
                } catch {
                    collector.fail(
                        index,
                        with: HealthKitError.parsingFailed(
                            "\(sample.parsingName) could not be parsed: \(error)"
                        )
                    )
                }
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
