//
//  Extensions+HKCorrelation.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

extension HKCorrelation: Harmonizable {
    typealias Harmonized = Correlation.Harmonized

    /// Member samples that fail to convert are skipped, as the factories skip samples
    func harmonize() throws -> Harmonized {
        return Harmonized(
            quantitySamples: objects
                .compactMap { $0 as? HKQuantitySample }
                .compactMap { try? Quantity(quantitySample: $0) },
            categorySamples: objects
                .compactMap { $0 as? HKCategorySample }
                .compactMap { try? Category(categorySample: $0) },
            metadata: metadata?.asMetadata
        )
    }
}
