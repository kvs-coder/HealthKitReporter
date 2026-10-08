//
//  Extensions+Encodable.swift
//  HealthKitReporter
//
//  Created by Victor on 01.10.20.
//

import Foundation

public extension Encodable {
    /**
     Encodes the payload as pretty printed JSON.
     Non-finite numbers, which JSON can't represent, are written as the strings
     "Infinity", "-Infinity" and "NaN" (what Dart's double.parse and JavaScript's Number accept)
     - Throws: **EncodingError**, HealthKitError.badEncoding
     - Returns: **String** JSON
     */
    func encoded() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )
        let data = try encoder.encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw HealthKitError.badEncoding("Impossible to encode: \(self)")
        }
        return string
    }
}
