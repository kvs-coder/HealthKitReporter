//
//  WorkoutRoute.swift
//  HealthKitReporter
//
//  Created by Florian on 24.11.20.
//

import Foundation
import CoreLocation

public struct WorkoutRoute: Codable {
    public struct Location: Codable {
        public let latitude: Double
        public let longitude: Double

        init(location: CLLocation) {
            let coordinate = location.coordinate
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
        }

        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    public let locations: [Location]
    public let done: Bool

    public init(locations: [Location], done: Bool) {
        self.locations = locations
        self.done = done
    }
}
