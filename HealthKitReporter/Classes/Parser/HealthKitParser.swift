//
//  HealthKitParser.swift
//  HealthKitReporter
//
//  Created by Florian on 25.09.20.
//

import Foundation
import HealthKit

class HealthKitParser {
    func parse(element: HKSample) -> Sample? {
        if let quantitySample = element as? HKQuantitySample {
            return try? quantitySample.parsed()
        }
        if let categorySample = element as? HKCategorySample {
            return try? categorySample.parsed()
        }
        if #available(iOS 14.0, *) {
            if let electrocardiogram = element as? HKElectrocardiogram {
                return try? electrocardiogram.parsed()
            }
        }
        return nil
    }
}
