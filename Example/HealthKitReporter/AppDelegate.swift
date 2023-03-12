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

    var observerUpdateHandler: ((Query?, String?, Error?) -> Void)?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let localNotificationManager = LocalNotificationManager()
        localNotificationManager.requestPermission { (_, _) in }
        let reporter = HealthKitReporter()
        let types: [SampleType] = [
            QuantityType.stepCount,
            QuantityType.heartRate,
            QuantityType.distanceCycling,
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
                        ) { (_, identifier, _) in
                            if let identifier = identifier {
                                let notification = LocalNotification(
                                    title: "Observed",
                                    subtitle: identifier
                                )
                                localNotificationManager.scheduleNotification(notification)
                            }
                        }
                        reporter.observer.enableBackgroundDelivery(
                            type: type,
                            frequency: .immediate
                        ) { (_, error) in
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
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler(
            [
                .alert,
                .badge,
                .sound
            ]
        )
    }
}
