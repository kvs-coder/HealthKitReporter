//
//  Extensions+HKSample.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

extension HKSample {
    func parsed() throws -> Sample {
        if #available(iOS 14.0, *) {
            if let electrocardiogram = self as? HKElectrocardiogram {
                return try Electrocardiogram(electrocardiogram: electrocardiogram)
            }
        }
        throw HealthKitError.parsingFailed("HKSample could not be parsed")
    }
}
