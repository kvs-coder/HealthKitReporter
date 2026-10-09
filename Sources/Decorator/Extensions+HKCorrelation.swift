//
//  Extensions+HKCorrelation.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

// MARK: - Harmonizable
extension HKCorrelation: Harmonizable {
    typealias Harmonized = Correlation.Harmonized

    /// A member sample that fails to convert fails the correlation
    func harmonize() throws -> Harmonized {
        return Harmonized(
            quantitySamples: try objects
                .compactMap { $0 as? HKQuantitySample }
                .converted(name: \.parsingName) { try Quantity(quantitySample: $0) },
            categorySamples: try objects
                .compactMap { $0 as? HKCategorySample }
                .converted(name: \.parsingName) { try Category(categorySample: $0) },
            metadata: metadata?.asMetadata
        )
    }
}
