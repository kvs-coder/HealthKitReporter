//
//  WorkoutRoute.swift
//  HealthKitReporter
//
//  Created by Victor on 24.11.20.
//

import Foundation
import CoreLocation

public struct WorkoutRoute: Codable {
    public struct Location: Codable {
        public let latitude: Double
        public let longitude: Double
        public let altitude: Double
        public let course: Double
        public let courseAccuracy: Double?
        public let floor: Int?
        public let horizontalAccuracy: Double
        public let speed: Double
        public let speedAccuracy: Double
        public let timestamp: Double
        public let verticalAccuracy: Double

        init(location: CLLocation) {
            let coordinate = location.coordinate
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
            self.altitude = location.altitude
            self.course = location.course
            if #available(iOS 13.4, *) {
                self.courseAccuracy = location.courseAccuracy
            } else {
                self.courseAccuracy = nil
            }
            self.floor = location.floor?.level
            self.horizontalAccuracy = location.horizontalAccuracy
            self.speed = location.speed
            self.speedAccuracy = location.speedAccuracy
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
            speedAccuracy: Double,
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

    public let locations: [Location]
    public let done: Bool

    public init(locations: [Location], done: Bool) {
        self.locations = locations
        self.done = done
    }
}
