//
//  Extensions+HKCorrelation.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

extension HKCorrelation: Harmonizable {
    public struct Harmonized: Codable {
        let quantitySamples: [Quantitiy]
        let categorySamples: [Category]
        let metadata: [String: String]?
    }

    func harmonize() throws -> Harmonized {
        var quantityArray = [Quantitiy]()
        if let quantitySamples = objects as? Set<HKQuantitySample> {
            for element in quantitySamples {
                let quantity = try Quantitiy(quantitySample: element)
                quantityArray.append(quantity)
            }
        }
        var categoryArray = [Category]()
        if let categorySamples = objects as? Set<HKCategorySample> {
            for element in categorySamples {
                let category = try Category(categorySample: element)
                categoryArray.append(category)
            }
        }
        return Harmonized(
            quantitySamples: quantityArray,
            categorySamples: categoryArray,
            metadata: self.metadata?.compactMapValues { String(describing: $0 )}
        )
    }
}
