//
//  HealthKitReporterWatchApp.swift
//  HealthKitReporterWatch
//
//  Created by Victor Kachalov on 08.10.26.
//

import SwiftUI

/// Watch companion launched by **HealthKitManager.startWatchApp(with:)** on the iPhone
@main
struct HealthKitReporterWatchApp: App {
    @WKApplicationDelegateAdaptor private var delegate: WatchAppDelegate

    var body: some Scene {
        WindowGroup {
            WorkoutView(session: delegate.session)
        }
    }
}
