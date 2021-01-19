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
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var writeButton: UIButton!
    
    private var reporter: HealthKitReporter?
    private let typesToRead: [QuantityType] = [
        .stepCount,
        .heartRate,
        .heartRateVariabilitySDNN
    ]
    private let typesToWrite: [QuantityType] = [
        .stepCount
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            reporter = try HealthKitReporter()
        } catch {
            print(error)
        }
        readButton.isEnabled = false
        writeButton.isEnabled = false
    }
    
    @IBAction func authorizeButtonTapped(_ sender: UIButton) {
        reporter?.manager.requestAuthorization(
            toRead: typesToRead,
            toWrite: typesToWrite
        ) { (success, error) in
            if success && error == nil {
                DispatchQueue.main.async { [unowned self] in
                    let alert = UIAlertController(
                        title: "HK",
                        message: "HK Authorized",
                        preferredStyle: .alert
                    )
                    alert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: .default
                        ) { [unowned self] (action) in
                            self.readButton.isEnabled = true
                            self.writeButton.isEnabled = true
                        }
                    )
                    self.present(alert, animated: true)
                }
            } else {
                print(error)
            }
        }
    }
    @IBAction func readButtonTapped(_ sender: UIButton) {
        read()
    }
    @IBAction func writeButtonTapped(_ sender: UIButton) {
        write { success, error in
            DispatchQueue.main.async { [unowned self] in
                let alert = UIAlertController(
                    title: "HK",
                    message: "HK writing - \(success). \(error != nil ? String(describing: error) : "No errors")",
                    preferredStyle: .alert
                )
                alert.addAction(
                    UIAlertAction(
                        title: "OK",
                        style: .default
                    )
                )
                self.present(alert, animated: true)
            }
        }
    }
    
    private func write(completionHandler: @escaping (Bool, Error?) -> Void) {
        let manager = reporter?.manager
        let writer = reporter?.writer
        manager?.preferredUnits(for: typesToWrite) { (preferredUnits, error) in
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
                writer?.save(sample: quantity, completion: completionHandler)
            }
        }
    }
    
    private func read() {
        let manager = reporter?.manager
        let reader = reporter?.reader
        manager?.preferredUnits(for: typesToRead) { [unowned self] (preferredUnits, error) in
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
                                            print("QUANTITY")
                                            print(try element.encoded())
                                        } catch {
                                            print(error)
                                        }
                                    }
                                } else {
                                    print(error)
                                }
                            }
                        ) {
                            manager?.executeQuery(quantityQuery)
                        }
                        if let statisticsQuery = try self.reporter?.reader.statisticsQuery(
                            type: try QuantityType.make(from: preferredUnit.identifier),
                            unit: preferredUnit.unit,
                            completionHandler: { (element, error) in
                                if error == nil {
                                    do {
                                        print("STATISTICS")
                                        print(try element.encoded())
                                    } catch {
                                        print(error)
                                    }
                                } else {
                                    print(error)
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
                print(error)
            }
        }
    }
}

