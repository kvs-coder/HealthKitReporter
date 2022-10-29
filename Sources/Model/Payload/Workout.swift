//
//  Workout.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

public struct Workout: Identifiable, Sample {
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

    init(workout: HKWorkout) throws {
        self.uuid = workout.uuid.uuidString
        self.identifier = workout.sampleType.identifier
        self.startTimestamp = workout.startDate.timeIntervalSince1970
        self.endTimestamp = workout.endDate.timeIntervalSince1970
        self.device = Device(device: workout.device)
        self.sourceRevision = SourceRevision(sourceRevision: workout.sourceRevision)
        self.duration = workout.duration
        guard #available(iOS 11.0, *) else {
            throw HealthKitError.notAvailable(
                "WorkoutEvents is not available for the current iOS"
            )
        }
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
    }

    public init(
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        device: Device?,
        sourceRevision: SourceRevision,
        duration: Double,
        workoutEvents: [WorkoutEvent],
        harmonized: Harmonized
    ) {
        self.uuid = UUID().uuidString
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.duration = duration
        self.workoutEvents = workoutEvents
        self.harmonized = harmonized
    }

    public func copyWith(
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        duration: Double? = nil,
        workoutEvents: [WorkoutEvent]? = nil,
        harmonized: Harmonized? = nil
    ) -> Workout {
        return Workout(
            identifier: identifier ?? self.identifier,
            startTimestamp: startTimestamp ?? self.startTimestamp,
            endTimestamp: endTimestamp ?? self.endTimestamp,
            device: device ?? self.device,
            sourceRevision: sourceRevision ?? self.sourceRevision,
            duration: duration ?? self.duration,
            workoutEvents: workoutEvents ?? self.workoutEvents,
            harmonized: harmonized ?? self.harmonized
        )
    }
}
// MARK: - Original
extension Workout: Original {
    func asOriginal() throws -> HKWorkout {
        guard let activityType = HKWorkoutActivityType(rawValue: UInt(harmonized.value)) else {
            throw HealthKitError.invalidType(
                "Workout type: \(harmonized.value) could not be formatted"
            )
        }
        guard #available(iOS 10.0, *) else {
            throw HealthKitError.notAvailable(
                "HKWorkout initializer is not available for the current iOS"
            )
        }
        return HKWorkout(
            activityType: activityType,
            start: startTimestamp.asDate,
            end: endTimestamp.asDate,
            workoutEvents: try workoutEvents.map { try $0.asOriginal() },
            totalEnergyBurned: harmonized.totalEnergyBurned != nil
                ? HKQuantity(
                    unit: HKUnit.init(from: harmonized.totalEnergyBurnedUnit),
                    doubleValue: harmonized.totalEnergyBurned!
                )
                : nil,
            totalDistance: harmonized.totalDistance != nil
                ? HKQuantity(
                    unit: HKUnit.init(from: harmonized.totalDistanceUnit),
                    doubleValue: harmonized.totalDistance!
                )
                : nil,
            totalSwimmingStrokeCount: harmonized.totalSwimmingStrokeCount != nil
                ? HKQuantity(
                    unit: HKUnit.init(from: harmonized.totalSwimmingStrokeCountUnit),
                    doubleValue: harmonized.totalSwimmingStrokeCount!
                )
                : nil,
            device: device?.asOriginal(),
            metadata: harmonized.metadata?.original
        )
    }
}
// MARK: - Payload
extension Workout: Payload {
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
        return Workout(
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
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
    public static func collect(
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
    public static func make(
        from dictionary: [String: Any]
    ) throws -> Workout.Harmonized {
        guard
            let value = dictionary["value"] as? Int,
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
            metadata: metadata?.asMetadata
        )
    }
}
