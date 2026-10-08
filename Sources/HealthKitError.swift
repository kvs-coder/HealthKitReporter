//
//  HealthKitError.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import Foundation

/// **HealthKitError** the only error the library throws; each case carries a descriptive message
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
// MARK: - LocalizedError
extension HealthKitError: LocalizedError {
    /// The descriptive message of the case, so `localizedDescription` shows it
    public var errorDescription: String? {
        switch self {
        case .notAvailable(let message),
             .unknown(let message),
             .invalidType(let message),
             .invalidIdentifier(let message),
             .invalidOption(let message),
             .invalidValue(let message),
             .parsingFailed(let message),
             .badEncoding(let message),
             .notImplementable(let message):
            return message
        }
    }
}
