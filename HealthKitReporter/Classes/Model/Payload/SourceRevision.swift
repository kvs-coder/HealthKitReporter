//
//  SourceRevision.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct SourceRevision: Codable, Original {
    public struct OperatingSystem: Codable {
        public let majorVersion: Int
        public let minorVersion: Int
        public let patchVersion: Int

        var original: OperatingSystemVersion {
            return OperatingSystemVersion(
                majorVersion: majorVersion,
                minorVersion: minorVersion,
                patchVersion: patchVersion
            )
        }

        init(version: OperatingSystemVersion) {
            self.majorVersion = version.majorVersion
            self.minorVersion = version.minorVersion
            self.patchVersion = version.patchVersion
        }

        public init(
            majorVersion: Int,
            minorVersion: Int,
            patchVersion: Int
        ) {
            self.majorVersion = majorVersion
            self.minorVersion = minorVersion
            self.patchVersion = patchVersion
        }
    }

    public let source: Source
    public let version: String?
    public let productType: String?
    public let systemVersion: String
    public let operatingSystem: OperatingSystem

    init(sourceRevision: HKSourceRevision) {
        self.source = Source(source: sourceRevision.source)
        self.version = sourceRevision.version
        self.productType = sourceRevision.productType
        self.systemVersion = sourceRevision.systemVersion
        self.operatingSystem = OperatingSystem(
            version: sourceRevision.operatingSystemVersion
        )
    }

    public init(
        source: Source,
        version: String?,
        productType: String?,
        systemVersion: String,
        operatingSystem: OperatingSystem
    ) {
        self.source = source
        self.version = version
        self.productType = productType
        self.systemVersion = systemVersion
        self.operatingSystem = operatingSystem
    }

    func asOriginal() throws -> HKSourceRevision {
        return HKSourceRevision(
            source: try source.asOriginal(),
            version: version,
            productType: productType,
            operatingSystemVersion: operatingSystem.original
        )
    }
}
