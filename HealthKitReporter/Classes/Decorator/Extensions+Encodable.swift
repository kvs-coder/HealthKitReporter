//
//  Extensions+Encodable.swift
//  HealthKitReporter
//
//  Created by Florian on 01.10.20.
//

import Foundation

extension Encodable {
    public func encoded() throws -> String{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw HealthKitError.badEncoding("Impossible to encode: \(self)")
        }
        return string
    }
}
