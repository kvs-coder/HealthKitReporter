//
//  WorkoutView.swift
//  HealthKitReporterWatch
//
//  Created by Victor Kachalov on 08.10.26.
//

import SwiftUI

/// Elapsed time and heart rate of the running workout, with an end button
struct WorkoutView: View {
    @ObservedObject var session: WorkoutSession

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(.pink)
                .symbolEffect(.pulse, isActive: isRunning)
            switch session.state {
            case .waiting:
                Text("Start a run from the iPhone demo")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            case .running(let name):
                Text(name).font(.headline)
                Text(Duration.seconds(session.elapsed).formatted(.time(pattern: .minuteSecond)))
                    .font(.system(.title, design: .rounded).monospacedDigit())
                Text(session.heartRate.map { "\(Int($0)) bpm" } ?? "-- bpm")
                    .foregroundStyle(.pink)
                Button("End", role: .destructive, action: session.end)
            case .ended(let summary):
                Text(summary).multilineTextAlignment(.center)
            case .failed(let message):
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private var isRunning: Bool {
        if case .running = session.state {
            return true
        }
        return false
    }
}
