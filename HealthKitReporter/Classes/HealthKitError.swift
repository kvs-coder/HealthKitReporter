//
//  HealthKitError.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import Foundation

public enum HealthKitError: Error {
    case notAvailable(String = "HealthKit data is not available")
    case unknown(String = "Unknown")
    case invalidType(String = "Invalid type")
    case invalidIdentifier(String = "Invalid identifier")
    case invalidOption(String = "Invalid option")
    case invalidValue(String = "Invalid value")
    case parsingFailed(String = "Parsing failed")
    case badEncoding(String)
    case notImplementable(String)
}
