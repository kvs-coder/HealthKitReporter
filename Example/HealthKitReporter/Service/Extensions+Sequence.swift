//
//  Extensions+Sequence.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Foundation

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
