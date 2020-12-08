//
//  AppDelegate.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09/14/2020.
//  Copyright (c) 2020 Victor Kachalov. All rights reserved.
//

import UIKit
import HealthKitReporter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        do {
            let reporter = try HealthKitReporter()
            let types: [SampleType] = [
                QuantityType.stepCount,
                CategoryType.sleepAnalysis
            ]
            reporter.manager.requestAuthorization(
                toRead: types,
                toWrite: types
            ) { (success, error) in
                if success && error == nil {
                    for type in types {
                        do {
                            let query = try reporter.observer.observerQuery(
                                type: type
                            ) { (query, identifier, error) in
                                if error == nil && identifier != nil {
                                    print("updates for \(identifier!)")
                                }
                            }
                            reporter.observer.enableBackgroundDelivery(
                                type: type,
                                frequency: .daily
                            ) { (success, error) in
                                if error == nil {
                                    print("enabled")
                                }
                            }
                            reporter.manager.executeQuery(query)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
        return true
    }
}

