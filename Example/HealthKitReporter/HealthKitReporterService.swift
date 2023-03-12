//
//  HealthKitReporterService.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 27.05.22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import HealthKitReporter

final class HealthKitReporterService {
    private var reporter: HealthKitReporter?

    private var typesToRead: [ObjectType] {
        var types: [ObjectType] = [
            QuantityType.stepCount,
            QuantityType.heartRate,
            QuantityType.bloodPressureSystolic,
            QuantityType.bloodPressureDiastolic,
            CategoryType.sleepAnalysis,
            QuantityType.heartRateVariabilitySDNN,
            SeriesType.heartbeatSeries,
            WorkoutType.workoutType,
            SeriesType.workoutRoute,
        ]
        if #available(iOS 14.0, *) {
            types.append(ElectrocardiogramType.electrocardiogramType)
        }
        return types
    }
    private let typesToWrite: [QuantityType] = [
        .stepCount,
        .bloodPressureSystolic,
        .bloodPressureDiastolic,
    ]

    private var predicate: NSPredicate {
        let now = Date()
        return Query.predicateForSamples(
            withStart: now.addingTimeInterval(-1 * 3600 * 3600 * 24),
            end: now,
            options: .strictEndDate
        )
    }

    init() {
        if HealthKitReporter.isHealthDataAvailable {
            reporter = HealthKitReporter()
        } else {
            print("HealthKitReporter is not available")
        }
    }

    func requestAuthorization(completion: @escaping StatusCompletionBlock) {
        reporter?.manager.requestAuthorization(
            toRead: typesToRead,
            toWrite: typesToWrite,
            completion: completion
        )
    }

    func readCategories() {
        let manager = reporter?.manager
        let reader = reporter?.reader
        if let categoryTypes = typesToRead.filter({ $0 is CategoryType}) as? [CategoryType] {
            for type in categoryTypes {
                do {
                    if let query = try reader?.categoryQuery(
                        type: type,
                        predicate: predicate,
                        resultsHandler: { results, error in
                        if error == nil {
                            for element in results {
                                do {
                                    print(try element.encoded())
                                } catch {
                                    print(error)
                                }
                            }
                        } else {
                            print(error ?? "error")
                        }
                    }) {
                        manager?.executeQuery(query)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }

    func readElectrocardiogram() {
        let manager = reporter?.manager
        let reader = reporter?.reader
        do {
            if #available(iOS 14.0, *) {
                if let seriesQuery = try reader?.electrocardiogramQuery(
                    predicate: predicate,
                    resultsHandler: { samples, error in
                        if error == nil {
                            do {
                                print("Electrocardiograms:", try samples.encoded())
                            } catch {
                                print(error)
                            }
                        } else {
                            print(error ?? "readElectrocardiogram error")
                        }
                    }) {
                    manager?.executeQuery(seriesQuery)
                }
            } else {
                print("ecg is not available")
            }
        } catch {
            print(error)
        }
    }

    func readHearbeatSeries() {
        let manager = reporter?.manager
        let reader = reporter?.reader
        do {
            if let seriesQuery = try reader?.heartbeatSeriesQuery(
                predicate: predicate,
                resultsHandler: { samples, error in
                if error == nil {
                    do {
                        print("HearbeatSeries", try samples.encoded())
                    } catch {
                        print(error)
                    }
                } else {
                    print(error ?? "readHearbeatSeries error")
                }
            }) {
                manager?.executeQuery(seriesQuery)
            }
        } catch {
            print(error)
        }
    }

    func readWorkoutRoutes() {
        let manager = reporter?.manager
        let reader = reporter?.reader
        do {
            if let seriesQuery = try reader?.workoutRouteQuery(
                predicate: predicate,
                resultsHandler: { samples, error in
                if error == nil {
                    do {
                        print("WorkoutRoutes:", try samples.encoded())
                    } catch {
                        print(error)
                    }
                } else {
                    print(error ?? "readWorkoutRoutes error")
                }
            }) {
                manager?.executeQuery(seriesQuery)
            }
        } catch {
            print(error)
        }
    }

    func readQuantitiesAndStatistics() {
        let manager = reporter?.manager
        let reader = reporter?.reader
        if let quantityTypes = typesToRead.filter({ $0 is QuantityType}) as? [QuantityType] {
            manager?.preferredUnits(for: quantityTypes) { (preferredUnits, error) in
                if error == nil {
                    for preferredUnit in preferredUnits {
                        do {
                            if let quantityQuery = try reader?.quantityQuery(
                                type: try QuantityType.make(from: preferredUnit.identifier),
                                unit: preferredUnit.unit,
                                resultsHandler: { (results, error) in
                                    if error == nil {
                                        for element in results {
                                            do {
                                                print("Quantity", try element.encoded())
                                            } catch {
                                                print(error)
                                            }
                                        }
                                    } else {
                                        print(error ?? "readQuantitiesAndStatistics error")
                                    }
                                }
                            ) {
                                manager?.executeQuery(quantityQuery)
                            }
                            if let statisticsQuery = try reader?.statisticsQuery(
                                type: try QuantityType.make(from: preferredUnit.identifier),
                                unit: preferredUnit.unit,
                                completionHandler: { (element, error) in
                                    if error == nil {
                                        do {
                                            print("Statistics", try element.encoded())
                                        } catch {
                                            print(error)
                                        }
                                    } else {
                                        print(error ?? "readQuantitiesAndStatistics error")
                                    }
                                }
                            ) {
                                manager?.executeQuery(statisticsQuery)
                            }
                        } catch {
                            print(error)
                        }
                    }
                } else {
                    print(error ?? "readQuantitiesAndStatistics error")
                }
            }
        }
    }

    func writeBloodPressureCorrelation() {
        let now = Date()
        let minuteAgo = now.addingTimeInterval(-60)
        let device = Device(
            name: "Guy's iPhone",
            manufacturer: "Guy",
            model: "6.1.1",
            hardwareVersion: "some_0",
            firmwareVersion: "some_1",
            softwareVersion: "some_2",
            localIdentifier: "some_3",
            udiDeviceIdentifier: "some_4"
        )
        let source = Source(
            name: "mySource",
            bundleIdentifier: "com.kvs.hkreporter"
        )
        let operatingSystem = SourceRevision.OperatingSystem(
            majorVersion: 1,
            minorVersion: 1,
            patchVersion: 1
        )
        let sourceRevision = SourceRevision(
            source: source,
            version: "1.0.0",
            productType: "CocoaPod",
            systemVersion: "1.0.0.0",
            operatingSystem: operatingSystem
        )
        let sys = Quantity(
            identifier: QuantityType.bloodPressureSystolic.identifier!,
            startTimestamp: minuteAgo.timeIntervalSince1970,
            endTimestamp: now.timeIntervalSince1970,
            device: device,
            sourceRevision: sourceRevision,
            harmonized: Quantity.Harmonized(
                value: 123.0,
                unit: "mmHg",
                metadata: ["you": "saved it"]
            )
        )
        let dias = Quantity(
            identifier: QuantityType.bloodPressureDiastolic.identifier!,
            startTimestamp: minuteAgo.timeIntervalSince1970,
            endTimestamp: now.timeIntervalSince1970,
            device: device,
            sourceRevision: sourceRevision,
            harmonized: Quantity.Harmonized(
                value: 83.0,
                unit: "mmHg",
                metadata: ["you": "saved it"]
            )
        )
        let correlation = Correlation(
            identifier: CorrelationType.bloodPressure.identifier!,
            startTimestamp: minuteAgo.timeIntervalSince1970,
            endTimestamp: now.timeIntervalSince1970,
            device: device, sourceRevision: sourceRevision,
            harmonized: Correlation.Harmonized(
                quantitySamples: [sys, dias],
                categorySamples: [],
                metadata: ["you": "saved it"]
            )
        )
        do {
            print("BloodPressureCorrelation:", try correlation.encoded())
            let writer = reporter?.writer
            writer?.save(sample: correlation) { success, error in
                print("BloodPressureCorrelation saved:", success)
                print("BloodPressureCorrelation erorr:", error ?? "no erorr")
            }
        } catch {
            print(error)
        }
    }

    func writeSteps() {
        let manager = reporter?.manager
        let writer = reporter?.writer
        manager?.preferredUnits(for: typesToWrite) { (preferredUnits, _) in
            for preferredUnit in preferredUnits {
                let identifier = preferredUnit.identifier
                guard
                    identifier == QuantityType.stepCount.identifier
                else {
                    return
                }
                let now = Date()
                let quantity = Quantity(
                    identifier: identifier,
                    startTimestamp: now.addingTimeInterval(-60).timeIntervalSince1970,
                    endTimestamp: now.timeIntervalSince1970,
                    device: Device(
                        name: "Guy's iPhone",
                        manufacturer: "Guy",
                        model: "6.1.1",
                        hardwareVersion: "some_0",
                        firmwareVersion: "some_1",
                        softwareVersion: "some_2",
                        localIdentifier: "some_3",
                        udiDeviceIdentifier: "some_4"
                    ),
                    sourceRevision: SourceRevision(
                        source: Source(
                            name: "mySource",
                            bundleIdentifier: "com.kvs.hkreporter"
                        ),
                        version: "1.0.0",
                        productType: "CocoaPod",
                        systemVersion: "1.0.0.0",
                        operatingSystem: SourceRevision.OperatingSystem(
                            majorVersion: 1,
                            minorVersion: 1,
                            patchVersion: 1
                        )
                    ),
                    harmonized: Quantity.Harmonized(
                        value: 123.0,
                        unit: preferredUnit.unit,
                        metadata: nil
                    )
                )
                do {
                    print("StepsQuantity:", try quantity.encoded())
                    writer?.save(sample: quantity) { success, error in
                        print("StepsQuantity saved:", success)
                        print("StepsQuantity erorr:", error ?? "error")
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}
