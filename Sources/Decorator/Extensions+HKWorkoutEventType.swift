//
//  File.swift
//  
//
//  Created by Kachalov, Victor on 04.09.21.
//

import HealthKit

extension HKWorkoutEventType {
    /// Name of the value in payload strings
    var label: String {
        switch self {
        case .pause:
            return "Pause"
        case .resume:
            return "Resume"
        case .lap:
            return "Lap"
        case .marker:
            return "Marker"
        case .motionPaused:
            return "Motion paused"
        case .motionResumed:
            return "Motion Resumed"
        case .segment:
            return "Segment"
        case .pauseOrResumeRequest:
            return "Pause or resume request"
        @unknown default:
            return "Unknown"
        }
    }
}
// MARK: - Validation
extension HKWorkoutEventType {
    /// The event type with this raw value; nil for values HealthKit doesn't know, which it raises for
    init?(knownRawValue rawValue: Int) {
        guard let type = HKWorkoutEventType(rawValue: rawValue), type.label != "Unknown" else {
            return nil
        }
        self = type
    }
}
