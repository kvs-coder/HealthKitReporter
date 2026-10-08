//
//  Extensions+HKCorrelation.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

extension HKCorrelation: Harmonizable {
    typealias Harmonized = Correlation.Harmonized

    func harmonize() throws -> Harmonized {
        return Harmonized(
            quantitySamples: try objects
                .compactMap { $0 as? HKQuantitySample }
                .map { try Quantity(quantitySample: $0) },
            categorySamples: try objects
                .compactMap { $0 as? HKCategorySample }
                .map { try Category(categorySample: $0) },
            metadata: metadata?.asMetadata
        )
    }
}
