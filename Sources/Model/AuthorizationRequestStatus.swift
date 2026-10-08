//
//  AuthorizationRequestStatus.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// Whether **HealthKitManager.requestAuthorization** would show the permission sheet
public enum AuthorizationRequestStatus: Int, Codable {
    case unknown = 0
    case shouldRequest = 1
    case unnecessary = 2

    init(requestStatus: HKAuthorizationRequestStatus) {
        switch requestStatus {
        case .unknown:
            self = .unknown
        case .shouldRequest:
            self = .shouldRequest
        case .unnecessary:
            self = .unnecessary
        @unknown default:
            self = .unknown
        }
    }
}
