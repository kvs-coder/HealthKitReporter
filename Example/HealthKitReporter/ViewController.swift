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
        do {
            let reporter = try HealthKitReporter()
            reporter.writer.requestAuthorization(
                toWrite: [.stepCount]) { (success, error) in
                if success && error == nil {
                    reporter.reader.preferredUnits(for: [.stepCount]) { (dictionary, error) in
                        if error == nil {
                            let quantity = Quantitiy(
                                identifier: HealthKitType.stepCount.rawValue!.identifier,
                                startTimestamp: Date().timeIntervalSince1970,
                                endTimestamp: Date().timeIntervalSince1970,
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
                                    systemVersion: "1.0.0.0"),
                                harmonized: Quantitiy.Harmonized(value: 123.0, unit: "count", metadata: nil)
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
            reporter.reader.requestAuthorization(
                toRead: [.stepCount]) { (success, error) in
                if success && error == nil {
                    reporter.reader.sampleQuery(type: .stepCount) { (results, error) in
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
                } else {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
}

