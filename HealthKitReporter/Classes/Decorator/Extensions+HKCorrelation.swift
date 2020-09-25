//
//  Extensions+HKCorrelation.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

extension HKCorrelation: HealthKitHarmonizable {
    public struct Harmonized: Codable {
        let quantitySamples: [Quantitiy]
        let categorySamples: [Category]
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
        return Harmonized(quantitySamples: quantityArray, categorySamples: categoryArray)
    }
}
