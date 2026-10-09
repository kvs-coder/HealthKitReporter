//
//  Extensions+Sequence.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09.10.26.
//

import Foundation

extension Sequence {
    /**
     Converts every element. The first element that fails to convert fails the whole result
     instead of being dropped.
     - Parameter name: names an element in the error message
     - Parameter convert: the conversion
     - Throws: HealthKitError.parsingFailed naming the element
     */
    func converted<Result>(
        name: (Element) -> String,
        _ convert: (Element) throws -> Result
    ) throws -> [Result] {
        return try map { element in
            do {
                return try convert(element)
            } catch {
                throw HealthKitError.parsingFailed("\(name(element)) could not be parsed: \(error)")
            }
        }
    }
}
