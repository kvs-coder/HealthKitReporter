//
//  Extensions+String.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Foundation

extension String {
    /// Long JSON cut so a cell stays readable
    var clipped: String {
        return count > 1_200 ? prefix(1_200) + "\n…" : self
    }
}
