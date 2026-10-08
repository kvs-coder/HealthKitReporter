//
//  CategoryValueDescribable.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import Foundation

/// A HealthKit category value enum that names its type and its value for **Category.Harmonized**
protocol CategoryValueDescribable {
    var label: String { get }
    var detail: String { get }
}
