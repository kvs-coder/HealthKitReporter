//
//  UpdateFrequency.swift
//  HealthKitReporter
//
//  Created by Victor on 13.11.20.
//

import HealthKit

public enum UpdateFrequency: Int {
    case immediate = 1
    case hourly = 2
    case daily = 3
    case weekly = 4

    var original: HKUpdateFrequency {
        switch self {
        case .immediate:
            return .immediate
        case .hourly:
            return .hourly
        case .daily:
            return .daily
        case .weekly:
            return .weekly
        }
    }

    public static func make(from integer: Int) throws -> Self {
        switch integer {
        case 1:
            return .immediate
        case 2:
            return .hourly
        case 3:
            return .daily
        case 4:
            return .weekly
        default:
            throw HealthKitError.invalidValue(
                "Integer: \(integer) can not be represented as UpdateFrequency"
            )
        }
    }
}
