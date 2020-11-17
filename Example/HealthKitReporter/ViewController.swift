//
//  ViewController.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09/14/2020.
//  Copyright (c) 2020 Victor Kachalov. All rights reserved.
//

import UIKit
import HealthKitReporter

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //read()
        //write()
    }

    private func write() {
        do {
            let reporter = try HealthKitReporter()
            let types = [QuantityType.stepCount]
            reporter.manager.requestAuthorization(
                toRead: types,
                toWrite: types
            ) { (success, error) in
                if success && error == nil {
                    reporter.manager.preferredUnits(for: types) { (preferredUnits, error) in
                        for preferredUnit in preferredUnits {
                            //Do write steps
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
                                ), sourceRevision: SourceRevision(
                                    source: Source(name: "mySource", bundleIdentifier: "com.kvs.hkreporter"),
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
                            reporter.writer.save(sample: quantity) { (success, error) in
                                if success && error == nil {
                                    print("success")
                                } else {
                                    print(error)
                                }
                            }
                        }
                    }
                } else {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }

    private func read() {
        do {
            let reporter = try HealthKitReporter()
            let types = [QuantityType.stepCount]
            reporter.manager.requestAuthorization(
                toRead: types,
                toWrite: types
            ) { (success, error) in
                if success && error == nil {
                    reporter.manager.preferredUnits(for: types) { (preferredUnits, error) in
                        if error == nil {
                            for preferredUnit in preferredUnits {
                                do {
                                    reporter.reader.quantityQuery(
                                        type: try QuantityType.make(from: preferredUnit.identifier),
                                        unit: preferredUnit.unit
                                    ) { (results, error) in
                                        if error == nil {
                                            for element in results {
                                                do {
                                                    print(try element.encoded())
                                                } catch {
                                                    print(error)
                                                }
                                            }
                                        } else {
                                            print(error)
                                        }
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                        } else {
                            print(error)
                        }
                    }
                } else {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
}

