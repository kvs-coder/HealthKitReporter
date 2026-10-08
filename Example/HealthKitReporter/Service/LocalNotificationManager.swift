//
//  LocalNotificationManager.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 09.12.20.
//  Copyright © 2020 Victor Kachalov. All rights reserved.
//

import UserNotifications

class LocalNotificationManager {
    func requestPermission(completionHandler: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [
                .alert,
                .badge,
                .sound
            ],
            completionHandler: completionHandler
        )
    }
    func scheduleNotification(_ notification: LocalNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.subtitle = notification.subtitle
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
