//
//  Extensions+HKSourceRevision.swift
//  HealthKitReporter
//
//  Created by Florian on 24.09.20.
//

import Foundation
import HealthKit

extension HKSourceRevision {
    var systemVersion: String {
        let major = self.operatingSystemVersion.majorVersion
        let minor = self.operatingSystemVersion.minorVersion
        let patch = self.operatingSystemVersion.patchVersion
        return "\(major).\(minor).\(patch)"
    }
}
