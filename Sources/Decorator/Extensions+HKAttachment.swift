//
//  Extensions+HKAttachment.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

@available(iOS 16.0, watchOS 9.0, *)
extension HKAttachment {
    func matches(_ identifier: String) -> Bool {
        return self.identifier.uuidString == identifier
    }
}
