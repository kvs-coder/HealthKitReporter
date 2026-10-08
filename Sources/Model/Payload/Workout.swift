//
//  Workout.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

/// **Workout** a workout with its events, totals, statistics and activities
public struct Workout: Identifiable, Sample {
    /// The value part of **Workout**, with its metadata
    public struct Harmonized: Codable {
        public let value: Int
        public let description: String
        public let totalEnergyBurned: Double?
        public let totalEnergyBurnedUnit: String
        public let totalDistance: Double?
        public let totalDistanceUnit: String
        public let totalSwimmingStrokeCount: Double?
        public let totalSwimmingStrokeCountUnit: String
        public let totalFlightsClimbed: Double?
        public let totalFlightsClimbedUnit: String
        public let metadata: Metadata?

        /// Creates the **Harmonized** from its fields
        public init(
            value: Int,
            description: String,
            totalEnergyBurned: Double?,
            totalEnergyBurnedUnit: String,
            totalDistance: Double?,
            totalDistanceUnit: String,
            totalSwimmingStrokeCount: Double?,
            totalSwimmingStrokeCountUnit: String,
            totalFlightsClimbed: Double?,
            totalFlightsClimbedUnit: String,
            metadata: Metadata?
        ) {
            self.value = value
            self.description = description
            self.totalEnergyBurned = totalEnergyBurned
            self.totalEnergyBurnedUnit = totalEnergyBurnedUnit
            self.totalDistance = totalDistance
            self.totalDistanceUnit = totalDistanceUnit
            self.totalSwimmingStrokeCount = totalSwimmingStrokeCount
            self.totalSwimmingStrokeCountUnit = totalSwimmingStrokeCountUnit
            self.totalFlightsClimbed = totalFlightsClimbed
            self.totalFlightsClimbedUnit = totalFlightsClimbedUnit
            self.metadata = metadata
        }

        /// A copy with the given fields replaced; nil keeps the current value
        public func copyWith(
            value: Int? = nil,
            description: String? = nil,
            totalEnergyBurned: Double? = nil,
            totalEnergyBurnedUnit: String? = nil,
            totalDistance: Double? = nil,
            totalDistanceUnit: String? = nil,
            totalSwimmingStrokeCount: Double? = nil,
            totalSwimmingStrokeCountUnit: String? = nil,
            totalFlightsClimbed: Double? = nil,
            totalFlightsClimbedUnit: String? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                value: value ?? self.value,
                description: description ?? self.description,
                totalEnergyBurned: totalEnergyBurned ?? self.totalEnergyBurned,
                totalEnergyBurnedUnit: totalEnergyBurnedUnit ?? self.totalEnergyBurnedUnit,
                totalDistance: totalDistance ?? self.totalDistance,
                totalDistanceUnit: totalDistanceUnit ?? self.totalDistanceUnit,
                totalSwimmingStrokeCount: totalSwimmingStrokeCount ?? self.totalSwimmingStrokeCount,
                totalSwimmingStrokeCountUnit: totalSwimmingStrokeCountUnit ?? self.totalSwimmingStrokeCountUnit,
                totalFlightsClimbed: totalFlightsClimbed ?? self.totalFlightsClimbed,
                totalFlightsClimbedUnit: totalFlightsClimbedUnit ?? self.totalFlightsClimbedUnit,
                metadata: metadata ?? self.metadata
            )
        }
    }

    public let uuid: String
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let duration: Double
    public let workoutEvents: [WorkoutEvent]
    public let harmonized: Harmonized
    /// statistics of every quantity type recorded during the workout, in SI units (iOS 16+)
    public let statistics: [Statistics]?
    /// activities of a multi-sport workout (iOS 16+)
    public let activities: [WorkoutActivity]?

    init(workout: HKWorkout) throws {
        self.uuid = workout.uuid.uuidString
        self.identifier = workout.sampleType.identifier
        self.startTimestamp = workout.startDate.timeIntervalSince1970
        self.endTimestamp = workout.endDate.timeIntervalSince1970
        self.device = Device(device: workout.device)
        self.sourceRevision = SourceRevision(sourceRevision: workout.sourceRevision)
        self.duration = workout.duration
        var workoutEvents = [WorkoutEvent]()
        if let events = workout.workoutEvents {
            for element in events {
                do {
                    let workoutEvent = try WorkoutEvent(workoutEvent: element)
                    workoutEvents.append(workoutEvent)
                } catch {
                    continue
                }
            }
        }
        self.workoutEvents = workoutEvents
        self.harmonized = try workout.harmonize()
        if #available(iOS 16.0, watchOS 9.0, *) {
            self.statistics = workout.allStatistics.values
                .compactMap { try? Statistics(statistics: $0) }
                .sorted { $0.identifier < $1.identifier }
            self.activities = workout.workoutActivities.map(WorkoutActivity.init(activity:))
        } else {
            self.statistics = nil
            self.activities = nil
        }
    }

    /**
     Creates the payload. **uuid** names the stored sample; a new one by default,
     since HealthKit gives every saved sample its own
     */
    public init(
        uuid: String = UUID().uuidString,
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        device: Device?,
        sourceRevision: SourceRevision,
        duration: Double,
        workoutEvents: [WorkoutEvent],
        harmonized: Harmonized,
        statistics: [Statistics]? = nil,
        activities: [WorkoutActivity]? = nil
    ) {
        self.uuid = uuid
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.duration = duration
        self.workoutEvents = workoutEvents
        self.harmonized = harmonized
        self.statistics = statistics
        self.activities = activities
    }

    /// A copy with the given fields replaced; nil keeps the current value, including the **uuid**
    public func copyWith(
        uuid: String? = nil,
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        duration: Double? = nil,
        workoutEvents: [WorkoutEvent]? = nil,
        harmonized: Harmonized? = nil,
        statistics: [Statistics]? = nil,
        activities: [WorkoutActivity]? = nil
    ) -> Workout {
        return Workout(
            uuid: uuid ?? self.uuid,
            identifier: identifier ?? self.identifier,
            startTimestamp: startTimestamp ?? self.startTimestamp,
            endTimestamp: endTimestamp ?? self.endTimestamp,
            device: device ?? self.device,
            sourceRevision: sourceRevision ?? self.sourceRevision,
            duration: duration ?? self.duration,
            workoutEvents: workoutEvents ?? self.workoutEvents,
            harmonized: harmonized ?? self.harmonized,
            statistics: statistics ?? self.statistics,
            activities: activities ?? self.activities
        )
    }
}
// MARK: - Original
extension Workout: Original {
    func asOriginal() throws -> HKWorkout {
        try startTimestamp.checkInterval(to: endTimestamp)
        guard let activityType = HKWorkoutActivityType(knownRawValue: harmonized.value) else {
            throw HealthKitError.invalidType(
                "Workout type: \(harmonized.value) could not be formatted"
            )
        }
        try checkTotals()
        let workoutEvents = try workoutEvents.map { try $0.asOriginal() }
        let totalEnergyBurned = try quantity(
            harmonized.totalEnergyBurned,
            unit: harmonized.totalEnergyBurnedUnit,
            compatibleWith: .activeEnergyBurned
        )
        let totalDistance = try quantity(
            harmonized.totalDistance,
            unit: harmonized.totalDistanceUnit,
            compatibleWith: .distanceWalkingRunning
        )
        if let totalFlightsClimbed = try quantity(
            harmonized.totalFlightsClimbed,
            unit: harmonized.totalFlightsClimbedUnit,
            compatibleWith: .flightsClimbed
        ) {
            return HKWorkout(
                activityType: activityType,
                start: startTimestamp.asDate,
                end: endTimestamp.asDate,
                workoutEvents: workoutEvents,
                totalEnergyBurned: totalEnergyBurned,
                totalDistance: totalDistance,
                totalFlightsClimbed: totalFlightsClimbed,
                device: device?.asOriginal(),
                metadata: try harmonized.metadata?.asOriginal()
            )
        }
        return HKWorkout(
            activityType: activityType,
            start: startTimestamp.asDate,
            end: endTimestamp.asDate,
            workoutEvents: workoutEvents,
            totalEnergyBurned: totalEnergyBurned,
            totalDistance: totalDistance,
            totalSwimmingStrokeCount: try quantity(
                harmonized.totalSwimmingStrokeCount,
                unit: harmonized.totalSwimmingStrokeCountUnit,
                compatibleWith: .swimmingStrokeCount
            ),
            device: device?.asOriginal(),
            metadata: try harmonized.metadata?.asOriginal()
        )
    }

    /// HKWorkout takes swimming strokes or flights climbed, not both; the builder takes both as samples
    private func checkTotals() throws {
        guard harmonized.totalSwimmingStrokeCount == nil || harmonized.totalFlightsClimbed == nil else {
            throw HealthKitError.invalidValue(
                "HKWorkout takes swimming strokes or flights climbed, not both; save it with saveWorkout"
            )
        }
    }
    /// The harmonized totals as samples spanning the workout, for **HKWorkoutBuilder**
    func totalSamples() throws -> [HKQuantitySample] {
        return try [
            totalSample(
                harmonized.totalEnergyBurned,
                unit: harmonized.totalEnergyBurnedUnit,
                of: .activeEnergyBurned
            ),
            totalSample(harmonized.totalDistance, unit: harmonized.totalDistanceUnit, of: distanceType),
            totalSample(
                harmonized.totalSwimmingStrokeCount,
                unit: harmonized.totalSwimmingStrokeCountUnit,
                of: .swimmingStrokeCount
            ),
            totalSample(
                harmonized.totalFlightsClimbed,
                unit: harmonized.totalFlightsClimbedUnit,
                of: .flightsClimbed
            )
        ].compactMap { $0 }
    }

    private func totalSample(
        _ value: Double?,
        unit: String,
        of identifier: HKQuantityTypeIdentifier
    ) throws -> HKQuantitySample? {
        return try quantity(value, unit: unit, compatibleWith: identifier).map {
            HKQuantitySample(
                type: HKQuantityType(identifier),
                quantity: $0,
                start: startTimestamp.asDate,
                end: endTimestamp.asDate
            )
        }
    }

    /// The distance type a workout of this activity records
    private var distanceType: HKQuantityTypeIdentifier {
        if #available(iOS 18.0, watchOS 11.0, *), let distanceType = newerDistanceType {
            return distanceType
        }
        switch HKWorkoutActivityType(knownRawValue: harmonized.value) {
        case .cycling, .handCycling:
            return .distanceCycling
        case .swimming:
            return .distanceSwimming
        case .wheelchairWalkPace, .wheelchairRunPace:
            return .distanceWheelchair
        case .downhillSkiing, .snowboarding:
            return .distanceDownhillSnowSports
        default:
            return .distanceWalkingRunning
        }
    }

    /// Distance types added in iOS 18
    @available(iOS 18.0, watchOS 11.0, *)
    private var newerDistanceType: HKQuantityTypeIdentifier? {
        switch HKWorkoutActivityType(knownRawValue: harmonized.value) {
        case .crossCountrySkiing:
            return .distanceCrossCountrySkiing
        case .paddleSports:
            return .distancePaddleSports
        case .rowing:
            return .distanceRowing
        case .skatingSports:
            return .distanceSkatingSports
        default:
            return nil
        }
    }

    private func quantity(
        _ value: Double?,
        unit: String,
        compatibleWith identifier: HKQuantityTypeIdentifier
    ) throws -> HKQuantity? {
        guard let value = value else {
            return nil
        }
        return HKQuantity(
            unit: try HKQuantityType(identifier).compatibleUnit(from: unit),
            doubleValue: value
        )
    }
}
// MARK: - Payload
extension Workout: Payload {
    /**
     Makes a **Workout** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(
        from dictionary: [String: Any]
    ) throws -> Workout {
        guard
            let identifier = dictionary["identifier"] as? String,
            let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
            let endTimestamp = dictionary["endTimestamp"] as? NSNumber,
            let duration = dictionary["duration"] as? NSNumber,
            let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let device = dictionary["device"] as? [String: Any]
        let workoutEvents = dictionary["workoutEvents"] as? [[String: Any]]
        let activities = dictionary["activities"] as? [[String: Any]]
        let statistics = dictionary["statistics"] as? [Any]
        return Workout(
            uuid: dictionary.payloadUUID,
            identifier: identifier,
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: Double(truncating: endTimestamp),
            device: device != nil
                ? try Device.make(from: device!)
                : nil,
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            duration: Double(truncating: duration),
            workoutEvents: workoutEvents != nil
                ? try workoutEvents!.map {
                    try WorkoutEvent.make(from: $0)
                }
                : [],
            harmonized: try Harmonized.make(from: harmonized),
            statistics: try statistics.map(Statistics.collect),
            activities: try activities?.map(WorkoutActivity.make)
        )
    }
    static func collect(
        results: [HKSample]
    ) -> [Workout] {
        var samples = [Workout]()
        if let workouts = results as? [HKWorkout] {
            for workout in workouts {
                do {
                    let sample = try Workout(
                        workout: workout
                    )
                    samples.append(sample)
                } catch {
                    continue
                }
            }
        }
        return samples
    }
}
// MARK: - Payload
extension Workout.Harmonized: Payload {
    /**
     Makes a **Workout.Harmonized** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(
        from dictionary: [String: Any]
    ) throws -> Workout.Harmonized {
        guard
            let value = dictionary.int("value"),
            let description = dictionary["description"] as? String,
            let totalEnergyBurnedUnit = dictionary["totalEnergyBurnedUnit"] as? String,
            let totalDistanceUnit = dictionary["totalDistanceUnit"] as? String,
            let totalSwimmingStrokeCountUnit = dictionary["totalSwimmingStrokeCountUnit"] as? String,
            let totalFlightsClimbedUnit = dictionary["totalFlightsClimbedUnit"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let totalEnergyBurned = dictionary["totalEnergyBurned"] as? NSNumber
        let totalDistance = dictionary["totalDistance"] as? NSNumber
        let totalSwimmingStrokeCount = dictionary["totalSwimmingStrokeCount"] as? NSNumber
        let totalFlightsClimbed = dictionary["totalFlightsClimbed"] as? NSNumber
        let metadata = dictionary["metadata"] as? [String: Any]
        return Workout.Harmonized(
            value: value,
            description: description,
            totalEnergyBurned: totalEnergyBurned != nil
                ? Double(truncating: totalEnergyBurned!)
                : nil,
            totalEnergyBurnedUnit: totalEnergyBurnedUnit,
            totalDistance:  totalDistance != nil
                ? Double(truncating: totalDistance!)
                : nil,
            totalDistanceUnit: totalDistanceUnit,
            totalSwimmingStrokeCount:  totalSwimmingStrokeCount != nil
                ? Double(truncating: totalSwimmingStrokeCount!)
                : nil,
            totalSwimmingStrokeCountUnit: totalSwimmingStrokeCountUnit,
            totalFlightsClimbed:  totalFlightsClimbed != nil
                ? Double(truncating: totalFlightsClimbed!)
                : nil,
            totalFlightsClimbedUnit: totalFlightsClimbedUnit,
            metadata: try metadata.map(Metadata.make)
        )
    }
}
