//
//  WorkoutRoute.swift
//  HealthKitReporter
//
//  Created by Victor on 24.11.20.
//

import HealthKit
import CoreLocation

@available(iOS 11.0, *)
public struct WorkoutRoute: Identifiable, Sample {
    public struct Route: Codable {
        public let locations: [Location]
        public let done: Bool

        public init(
            locations: [Location],
            done: Bool
        ) {
            self.locations = locations
            self.done = done
        }
    }

    public struct Location: Codable {
        public let latitude: Double
        public let longitude: Double
        public let altitude: Double
        public let course: Double
        public let courseAccuracy: Double?
        public let floor: Int?
        public let horizontalAccuracy: Double
        public let speed: Double
        public let speedAccuracy: Double?
        public let timestamp: Double
        public let verticalAccuracy: Double

        init(location: CLLocation) {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.altitude = location.altitude
            self.course = location.course
            if #available(iOS 13.4, *) {
                self.courseAccuracy = !location.courseAccuracy.isNaN
                    ? location.courseAccuracy
                    : nil
            } else {
                self.courseAccuracy = nil
            }
            self.floor = location.floor?.level
            self.horizontalAccuracy = location.horizontalAccuracy
            self.speed = location.speed
            self.speedAccuracy = !location.speedAccuracy.isNaN
                ? location.speedAccuracy
                : nil
            self.timestamp = location.timestamp.timeIntervalSince1970
            self.verticalAccuracy = location.verticalAccuracy
        }

        public init(
            latitude: Double,
            longitude: Double,
            altitude: Double,
            course: Double,
            courseAccuracy: Double?,
            floor: Int?,
            horizontalAccuracy: Double,
            speed: Double,
            speedAccuracy: Double?,
            timestamp: Double,
            verticalAccuracy: Double
        ) {
            self.latitude = latitude
            self.longitude = longitude
            self.altitude = altitude
            self.course = course
            self.courseAccuracy = courseAccuracy
            self.floor = floor
            self.horizontalAccuracy = horizontalAccuracy
            self.speed = speed
            self.speedAccuracy = speedAccuracy
            self.timestamp = timestamp
            self.verticalAccuracy = verticalAccuracy
        }
    }

    public struct Harmonized: Codable {
        public let count: Int
        public let routes: [Route]
        public let metadata: Metadata?

        public init(
            count: Int,
            routes: [Route],
            metadata: Metadata?
        ) {
            self.count = count
            self.routes = routes
            self.metadata = metadata
        }

        public func copyWith(
            count: Int? = nil,
            routes: [Route]? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                count: count ?? self.count,
                routes: routes ?? self.routes,
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
    public let harmonized: Harmonized

    public init(
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        device: Device?,
        sourceRevision: SourceRevision,
        harmonized: Harmonized
    ) {
        self.uuid = UUID().uuidString
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.harmonized = harmonized
    }

    init(sample: HKWorkoutRoute, routes: [Route]) {
        self.uuid = sample.uuid.uuidString
        self.identifier = sample.sampleType.identifier
        self.startTimestamp = sample.startDate.timeIntervalSince1970
        self.endTimestamp = sample.endDate.timeIntervalSince1970
        self.device = Device(device: sample.device)
        self.sourceRevision = SourceRevision(sourceRevision: sample.sourceRevision)
        self.harmonized = sample.harmonize(routes: routes)
    }
}
// MARK: - Payload
@available(iOS 11.0, *)
extension WorkoutRoute.Location: Payload {
    public static func make(from dictionary: [String: Any]) throws -> WorkoutRoute.Location {
        guard
            let latitude = dictionary["latitude"] as? NSNumber,
            let longitude = dictionary["longitude"] as? NSNumber,
            let altitude = dictionary["altitude"] as? NSNumber,
            let course = dictionary["course"] as? NSNumber,
            let horizontalAccuracy = dictionary["horizontalAccuracy"] as? NSNumber,
            let speed = dictionary["speed"] as? NSNumber,
            let timestamp = dictionary["timestamp"] as? NSNumber,
            let verticalAccuracy = dictionary["verticalAccuracy"] as? NSNumber
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let floor = dictionary["floor"] as? NSNumber
        let courseAccuracy = dictionary["courseAccuracy"] as? NSNumber
        let speedAccuracy = dictionary["speedAccuracy"] as? NSNumber
        return WorkoutRoute.Location(
            latitude: Double(truncating: latitude),
            longitude: Double(truncating: longitude),
            altitude: Double(truncating: altitude),
            course: Double(truncating: course),
            courseAccuracy: courseAccuracy != nil
                ? Double(truncating: courseAccuracy!)
                : nil,
            floor: floor != nil
                ? Int(truncating: floor!)
                : nil,
            horizontalAccuracy: Double(truncating: horizontalAccuracy),
            speed: Double(truncating: speed),
            speedAccuracy: speedAccuracy != nil
                ? Double(truncating: speedAccuracy!)
                : nil,
            timestamp: Double(truncating: timestamp),
            verticalAccuracy: Double(truncating: verticalAccuracy)
        )
    }
    public static func collect(from array: [Any]) throws -> [WorkoutRoute.Location] {
        var locations = [WorkoutRoute.Location]()
        for element in array {
            if let dictionary = element as? [String: Any] {
                let location = try WorkoutRoute.Location.make(from: dictionary)
                locations.append(location)
            }
        }
        return locations
    }
}
// MARK: - Payload
@available(iOS 11.0, *)
extension WorkoutRoute: Payload {
    public static func make(from dictionary: [String: Any]) throws -> WorkoutRoute {
        guard
            let identifier = dictionary["identifier"] as? String,
            let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
            let endTimestamp = dictionary["endTimestamp"] as? NSNumber,
            let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let device = dictionary["device"] as? [String: Any]
        return WorkoutRoute(
            identifier: identifier,
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: Double(truncating: endTimestamp),
            device: device != nil
                ? try Device.make(from: device!)
                : nil,
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
// MARK: - Payload
@available(iOS 11.0, *)
extension WorkoutRoute.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> WorkoutRoute.Harmonized {
        guard
            let count = dictionary["count"] as? Int,
            let routes = dictionary["routes"] as? [Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return WorkoutRoute.Harmonized(
            count: count,
            routes: try WorkoutRoute.Route.collect(from: routes),
            metadata: metadata?.asMetadata
        )
    }
}
// MARK: - Payload
@available(iOS 11.0, *)
extension WorkoutRoute.Route: Payload {
    public static func make(from dictionary: [String: Any]) throws -> WorkoutRoute.Route {
        guard
            let locations = dictionary["locations"] as? [Any],
            let done = dictionary["done"] as? Bool
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return WorkoutRoute.Route(
            locations: try WorkoutRoute.Location.collect(from: locations),
            done: done
        )
    }
    public static func collect(from array: [Any]) throws -> [WorkoutRoute.Route] {
        var routes = [WorkoutRoute.Route]()
        for element in array {
            if let dictionary = element as? [String: Any] {
                let route = try WorkoutRoute.Route.make(from: dictionary)
                routes.append(route)
            }
        }
        return routes
    }
}
