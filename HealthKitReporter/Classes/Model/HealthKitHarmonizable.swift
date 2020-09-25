//
//  HealthKitHarmonizable.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation

protocol HealthKitHarmonizable {
    associatedtype Harmonized: Codable

    func harmonize() throws -> Harmonized
}
