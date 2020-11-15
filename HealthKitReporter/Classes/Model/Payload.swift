//
//  Payload.swift
//  HealthKitReporter
//
//  Created by Florian on 15.11.20.
//

import Foundation

public protocol Payload {
    static func make(from dictionary: [String: Any]) throws -> Self
}
