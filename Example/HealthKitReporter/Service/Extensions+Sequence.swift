//
//  Extensions+Sequence.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Foundation
import HealthKitReporter

extension Sequence {
    /// "N <noun>" followed by the first element as JSON, what a demo row shows for a list result
    func summary(_ noun: String) -> String {
        let items = Array(self)
        guard
            let first = items.first as? Encodable,
            let json = try? first.encoded()
        else {
            return "\(items.count) \(noun)"
        }
        return "\(items.count) \(noun), first:\n\(json.clipped)"
    }
}

extension String {
    /// Long JSON cut so a cell stays readable
    var clipped: String {
        return count > 1_200 ? prefix(1_200) + "\n…" : self
    }
}

extension Encodable {
    /// The value as JSON, or the encoding error
    var json: String {
        return (try? encoded())?.clipped ?? "Could not encode \(self)"
    }
}
