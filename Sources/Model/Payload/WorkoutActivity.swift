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

    /// Creates the **WorkoutActivity** from its fields
    public init(
        uuid: String = UUID().uuidString,
        activityValue: Int,
        activityDescription: String,
        locationValue: Int,
        swimmingLocationValue: Int,
        lapLength: Double?,
        startTimestamp: Double,
        endTimestamp: Double?,
        metadata: Metadata?
    ) {
        self.init(
            uuid: uuid,
            activityValue: activityValue,
            activityDescription: activityDescription,
            locationValue: locationValue,
            swimmingLocationValue: swimmingLocationValue,
            lapLength: lapLength,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            duration: (endTimestamp ?? startTimestamp) - startTimestamp,
            workoutEvents: [],
            statistics: [],
            metadata: metadata
        )
    }

    private init(
        uuid: String,
        activityValue: Int,
        activityDescription: String,
        locationValue: Int,
        swimmingLocationValue: Int,
        lapLength: Double?,
        startTimestamp: Double,
        endTimestamp: Double?,
        duration: Double,
        workoutEvents: [WorkoutEvent],
        statistics: [Statistics],
        metadata: Metadata?
    ) {
        self.uuid = uuid
        self.activityValue = activityValue
        self.activityDescription = activityDescription
        self.locationValue = locationValue
        self.swimmingLocationValue = swimmingLocationValue
        self.lapLength = lapLength
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.duration = duration
        self.workoutEvents = workoutEvents
        self.statistics = statistics
        self.metadata = metadata
    }

    /// A copy with the given fields replaced; the duration follows the timestamps
    public func copyWith(
        uuid: String? = nil,
        activityValue: Int? = nil,
        activityDescription: String? = nil,
        locationValue: Int? = nil,
        swimmingLocationValue: Int? = nil,
        lapLength: Double? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        metadata: Metadata? = nil
    ) -> WorkoutActivity {
        let start = startTimestamp ?? self.startTimestamp
        let end = endTimestamp ?? self.endTimestamp
        return WorkoutActivity(
            uuid: uuid ?? self.uuid,
            activityValue: activityValue ?? self.activityValue,
            activityDescription: activityDescription ?? self.activityDescription,
            locationValue: locationValue ?? self.locationValue,
            swimmingLocationValue: swimmingLocationValue ?? self.swimmingLocationValue,
            lapLength: lapLength ?? self.lapLength,
            startTimestamp: start,
            endTimestamp: end,
            duration: startTimestamp == nil && endTimestamp == nil ? duration : (end ?? start) - start,
            workoutEvents: workoutEvents,
            statistics: statistics,
            metadata: metadata ?? self.metadata
        )
    }

    @available(iOS 16.0, watchOS 9.0, *)
    init(activity: HKWorkoutActivity) throws {
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
        self.workoutEvents = try activity.workoutEvents.converted(name: \.parsingName) {
            try WorkoutEvent(workoutEvent: $0)
        }
        self.statistics = try activity.allStatistics.values
            .converted(name: \.parsingName) { try Statistics(statistics: $0) }
            .sorted { $0.identifier < $1.identifier }
        self.metadata = activity.metadata?.asMetadata
    }
}
// MARK: - Original
@available(iOS 16.0, watchOS 9.0, *)
extension WorkoutActivity: Original {
    func asOriginal() throws -> HKWorkoutActivity {
        try startTimestamp.checkInterval(to: endTimestamp)
        guard let activityType = HKWorkoutActivityType(knownRawValue: activityValue) else {
            throw HealthKitError.invalidType("Workout activity type: \(activityValue) could not be formatted")
        }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        try configure(configuration)
        return HKWorkoutActivity(
            workoutConfiguration: configuration,
            start: startTimestamp.asDate,
            end: endTimestamp?.asDate,
            metadata: try metadata?.asOriginal()
        )
    }
}
// MARK: - Configuration
@available(iOS 16.0, watchOS 9.0, *)
extension WorkoutActivity {
    /// Sets the location, swimming location and lap length of the activity on a workout configuration
    func configure(_ configuration: HKWorkoutConfiguration) throws {
        try configuration.setLocations(location: locationValue, swimmingLocation: swimmingLocationValue)
        configuration.lapLength = lapLength.map { HKQuantity(unit: .meter(), doubleValue: $0) }
    }
}
// MARK: - Payload
extension WorkoutActivity: Payload {
    /**
     Makes a **WorkoutActivity** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
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
            uuid: dictionary.payloadUUID,
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
