//
//  Identifiable.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation

protocol Identifiable: Codable {
    var identifier: String { get }
}


