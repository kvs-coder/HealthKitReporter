//
//  SourceRevision.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct SourceRevision: Codable {
    public let source: Source
    public let version: String?
    public let productType: String?
    public let systemVersion: String

    public init(sourceRevision: HKSourceRevision) {
        self.source = Source(source: sourceRevision.source)
        self.version = sourceRevision.version
        self.productType = sourceRevision.productType
        self.systemVersion = sourceRevision.systemVersion
    }

    public init(
        source: Source,
        version: String?,
        productType: String?,
        systemVersion: String
    ) {
        self.source = source
        self.version = version
        self.productType = productType
        self.systemVersion = systemVersion
    }
}
