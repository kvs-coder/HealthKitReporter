//
//  HealthKitError.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import Foundation

@objc(HKRError)
public final class HealthKitError: NSError {
    private static let domain = "HKR"

    @objc
    static func notAvailable(_ message: String = "HealthKit data is not available") -> HealthKitError {
        HealthKitError(
            domain: domain,
            code: 100,
            userInfo: ["message": message]
        )
    }
    @objc
    static func unknown(_ message: String = "Unknown") -> HealthKitError {
        HealthKitError(
            domain: domain,
            code: 101,
            userInfo: ["message": message]
        )
    }
    @objc
    static func invalidType(_ message: String = "Invalid type") -> HealthKitError {
        HealthKitError(
            domain: domain,
            code: 102,
            userInfo: ["message": message]
        )
    }
    @objc
    static func invalidIdentifier(_ message: String = "Invalid identifier") -> HealthKitError {
        HealthKitError(
            domain: domain,
            code: 103,
            userInfo: ["message": message]
        )
    }
    @objc
    static func invalidOption(_ message: String = "Invalid option") -> HealthKitError {
        HealthKitError(
            domain: domain,
            code: 104,
            userInfo: ["message": message]
        )
    }
    @objc
    static func invalidValue(_ message: String = "Invalid value") -> HealthKitError {
        HealthKitError(
            domain: domain,
            code: 105,
            userInfo: ["message": message]
        )
    }
    @objc
    static func parsingFailed(_ message: String = "Invalid failed") -> HealthKitError {
        HealthKitError(
            domain: domain,
            code: 106,
            userInfo: ["message": message]
        )
    }
    @objc
    static func badEncoding(_ message: String = "Bad encoding") -> HealthKitError {
        HealthKitError(
            domain: domain,
            code: 107,
            userInfo: ["message": message]
        )
    }
    @objc
    static func notImplementable(_ message: String = "Not implementable") -> HealthKitError {
        HealthKitError(
            domain: domain,
            code: 108,
            userInfo: ["message": message]
        )
    }
}
