//
//  SourceRevision.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

public struct SourceRevision: Codable {
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

        public func copyWith(
            majorVersion: Int? = nil,
            minorVersion: Int? = nil,
            patchVersion: Int? = nil
        ) -> OperatingSystem {
            return OperatingSystem(
                majorVersion: majorVersion ?? self.majorVersion,
                minorVersion: minorVersion ?? self.minorVersion,
                patchVersion: patchVersion ?? self.patchVersion
            )
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
        if #available(iOS 11.0, *) {
            self.productType = sourceRevision.productType
            self.systemVersion = sourceRevision.systemVersion
            self.operatingSystem = OperatingSystem(
                version: sourceRevision.operatingSystemVersion
            )
        } else {
            self.productType = nil
            self.systemVersion = "10.0.0"
            self.operatingSystem = OperatingSystem(
                majorVersion: 10,
                minorVersion: 0,
                patchVersion: 0
            )
        }
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

    public func copyWith(
        source: Source? = nil,
        version: String? = nil,
        productType: String? = nil,
        systemVersion: String? = nil,
        operatingSystem: OperatingSystem? = nil
    ) -> SourceRevision {
        return SourceRevision(
            source: source ?? self.source,
            version: version ?? self.version,
            productType: productType ?? self.productType,
            systemVersion: systemVersion ?? self.systemVersion,
            operatingSystem: operatingSystem ?? self.operatingSystem
        )
    }
}
// MARK: - Original
extension SourceRevision: Original {
    func asOriginal() throws -> HKSourceRevision {
        if #available(iOS 11.0, *) {
            return HKSourceRevision(
                source: try source.asOriginal(),
                version: version,
                productType: productType,
                operatingSystemVersion: operatingSystem.original
            )
        } else {
            throw HealthKitError.notAvailable(
                "HKSourceRevision is not available for the current iOS"
            )
        }
    }
}
// MARK: - Payload
extension SourceRevision.OperatingSystem: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws -> SourceRevision.OperatingSystem {
        guard
            let majorVersion = dictionary["majorVersion"] as? Int,
            let minorVersion = dictionary["minorVersion"] as? Int,
            let patchVersion = dictionary["patchVersion"] as? Int
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return SourceRevision.OperatingSystem(
            majorVersion: majorVersion,
            minorVersion: minorVersion,
            patchVersion: patchVersion
        )
    }
}
// MARK: - Payload
extension SourceRevision: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws -> SourceRevision {
        guard
            let systemVersion = dictionary["systemVersion"] as? String,
            let operatingSystem = dictionary["operatingSystem"] as? [String: Any],
            let source = dictionary["source"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let version = dictionary["version"] as? String
        let productType = dictionary["productType"] as? String
        return SourceRevision(
            source: try Source.make(from: source),
            version: version,
            productType: productType,
            systemVersion: systemVersion,
            operatingSystem: try OperatingSystem.make(from: operatingSystem)
        )
    }
}
