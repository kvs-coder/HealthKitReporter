//
//  WorkoutActivity.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// One activity of a multi-sport workout, e.g. the swim of a triathlon (iOS 16+)
public struct WorkoutActivity: Codable {
    public let uuid: String
    /// **HKWorkoutActivityType** raw value
    public let activityValue: Int
    public let activityDescription: String
    /// **HKWorkoutSessionLocationType** raw value
    public let locationValue: Int
    /// **HKWorkoutSwimmingLocationType** raw value
    public let swimmingLocationValue: Int
    /// meters
    public let lapLength: Double?
    /// seconds since 1970
    public let startTimestamp: Double
    /// seconds since 1970
    public let endTimestamp: Double?
    /// seconds
    public let duration: Double
    public let workoutEvents: [WorkoutEvent]
    /// statistics of every quantity type recorded during the activity, in SI units
    public let statistics: [Statistics]
    public let metadata: Metadata?

    public init(
        activityValue: Int,
        activityDescription: String,
        locationValue: Int,
        swimmingLocationValue: Int,
        lapLength: Double?,
        startTimestamp: Double,
        endTimestamp: Double?,
        metadata: Metadata?
    ) {
        self.uuid = UUID().uuidString
        self.activityValue = activityValue
        self.activityDescription = activityDescription
        self.locationValue = locationValue
        self.swimmingLocationValue = swimmingLocationValue
        self.lapLength = lapLength
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.duration = (endTimestamp ?? startTimestamp) - startTimestamp
        self.workoutEvents = []
        self.statistics = []
        self.metadata = metadata
    }

    @available(iOS 16.0, watchOS 9.0, *)
    init(activity: HKWorkoutActivity) {
        let configuration = activity.workoutConfiguration
        self.uuid = activity.uuid.uuidString
        self.activityValue = Int(configuration.activityType.rawValue)
        self.activityDescription = configuration.activityType.label
        self.locationValue = configuration.locationType.rawValue
        self.swimmingLocationValue = configuration.swimmingLocationType.rawValue
        self.lapLength = configuration.lapLength?.doubleValue(for: .meter())
        self.startTimestamp = activity.startDate.timeIntervalSince1970
        self.endTimestamp = activity.endDate?.timeIntervalSince1970
        self.duration = activity.duration
        self.workoutEvents = activity.workoutEvents.compactMap { try? WorkoutEvent(workoutEvent: $0) }
        self.statistics = activity.allStatistics.values
            .compactMap { try? Statistics(statistics: $0) }
            .sorted { $0.identifier < $1.identifier }
        self.metadata = activity.metadata?.asMetadata
    }
}
// MARK: - Original
@available(iOS 16.0, watchOS 9.0, *)
extension WorkoutActivity: Original {
    func asOriginal() throws -> HKWorkoutActivity {
        guard let activityType = HKWorkoutActivityType(knownRawValue: activityValue) else {
            throw HealthKitError.invalidType("Workout activity type: \(activityValue) could not be formatted")
        }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        if let locationType = HKWorkoutSessionLocationType(knownRawValue: locationValue) {
            configuration.locationType = locationType
        }
        if let swimmingLocationType = HKWorkoutSwimmingLocationType(knownRawValue: swimmingLocationValue) {
            configuration.swimmingLocationType = swimmingLocationType
        }
        configuration.lapLength = lapLength.map { HKQuantity(unit: .meter(), doubleValue: $0) }
        return HKWorkoutActivity(
            workoutConfiguration: configuration,
            start: startTimestamp.asDate,
            end: endTimestamp?.asDate,
            metadata: try metadata?.asOriginal()
        )
    }
}
// MARK: - Payload
extension WorkoutActivity: Payload {
    public static func make(from dictionary: [String: Any]) throws -> WorkoutActivity {
        guard
            let activityValue = dictionary["activityValue"] as? NSNumber,
            let activityDescription = dictionary["activityDescription"] as? String,
            let locationValue = dictionary["locationValue"] as? NSNumber,
            let swimmingLocationValue = dictionary["swimmingLocationValue"] as? NSNumber,
            let startTimestamp = dictionary["startTimestamp"] as? NSNumber
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return WorkoutActivity(
            activityValue: activityValue.intValue,
            activityDescription: activityDescription,
            locationValue: locationValue.intValue,
            swimmingLocationValue: swimmingLocationValue.intValue,
            lapLength: (dictionary["lapLength"] as? NSNumber).map { Double(truncating: $0) },
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: (dictionary["endTimestamp"] as? NSNumber).map { Double(truncating: $0) },
            metadata: try metadata.map(Metadata.make)
        )
    }
}
