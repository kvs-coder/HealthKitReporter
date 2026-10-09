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
        return try map { sample in
            do {
                return try sample.parsed()
            } catch {
                throw HealthKitError.parsingFailed(
                    "\(sample.sampleType.identifier) sample \(sample.uuid.uuidString) "
                        + "could not be parsed: \(error)"
                )
            }
        }
    }
}
