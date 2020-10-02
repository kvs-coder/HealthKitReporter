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

