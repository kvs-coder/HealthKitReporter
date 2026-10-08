//
//  Extensions+Encodable.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Foundation
import HealthKitReporter

extension Encodable {
    /// The value as JSON, or the encoding error
    var json: String {
        return (try? encoded())?.clipped ?? "Could not encode \(self)"
    }
}
