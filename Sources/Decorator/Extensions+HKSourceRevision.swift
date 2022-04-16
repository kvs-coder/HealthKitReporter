//
//  Extensions+HKSourceRevision.swift
//  HealthKitReporter
//
//  Created by Victor on 24.09.20.
//

import HealthKit

extension HKSourceRevision {
    @available(iOS 11.0, *)
    var systemVersion: String {
        let major = operatingSystemVersion.majorVersion
        let minor = operatingSystemVersion.minorVersion
        let patch = operatingSystemVersion.patchVersion
        return "\(major).\(minor).\(patch)"
    }
}
