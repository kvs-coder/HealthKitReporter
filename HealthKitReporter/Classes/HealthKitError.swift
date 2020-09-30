//
//  HealthKitError.swift
//  HealthKitReporter
//
//  Created by KVS on 24.09.20.
//

import Foundation

enum HealthKitError: Error {
    case notAvailable(String = "HealthKit data is not available")
    case unknown(String = "Unknown")
    case invalidType(String = "Invalid type")
    case invalidOption(String = "Invalid option")
    case invalidValue(String = "Invalid value")
    case parsingFailed(String = "Parsing failed")
}
