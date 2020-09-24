//
//  HealthKitParser.swift
//  HealthKitReporter
//
//  Created by Florian on 24.09.20.
//

import Foundation
import HealthKit

class HealthKitParser {
    func parse(element: HKSample) -> Sample? {
        if let quantitySample = element as? HKQuantitySample {
            return Quantitiy(quantitySample: quantitySample)
        }
        if let categorySample = element as? HKCategorySample {
            return Category(categorySample: categorySample)
        }
        if #available(iOS 14.0, *) {
            if let electrocardiogram = element as? HKElectrocardiogram {
                return Electrocardiogram(electrocardiogram: electrocardiogram)
            }
        }
        return nil
    }
}
