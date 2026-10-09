//
//  Extensions+Array.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 09.10.26.
//

import HealthKit

extension Array where Element == HKSample {
    /// The payloads of every sample; a sample that fails to parse fails the whole result
    /// instead of being dropped
    func parsedSamples() throws -> [Sample] {
        return try converted { (sample: HKSample) in try sample.parsed() }
    }
    /**
     Converts every sample of the **Source** class. A sample of another class, or one that fails
     to convert, fails the whole result instead of being dropped.
     - Parameter convert: the conversion
     - Throws: HealthKitError.parsingFailed naming the sample type and uuid
     */
    func converted<Source: HKSample, Result>(_ convert: (Source) throws -> Result) throws -> [Result] {
        return try converted(name: \.parsingName) { sample in
            guard let source = sample as? Source else {
                throw HealthKitError.invalidType("\(sample.parsingName) is not \(Source.self)")
            }
            return try convert(source)
        }
    }
}
