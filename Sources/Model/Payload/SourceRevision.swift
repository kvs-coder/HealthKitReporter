//
//  SourceRevision.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

/// **SourceRevision** the version of the source that saved a sample
public struct SourceRevision: Codable {
    /// **OperatingSystem** the operating system version of a source revision
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

        /// Creates the **OperatingSystem** from its fields
        public init(
            majorVersion: Int,
            minorVersion: Int,
            patchVersion: Int
        ) {
            self.majorVersion = majorVersion
            self.minorVersion = minorVersion
            self.patchVersion = patchVersion
        }

        /// A copy with the given fields replaced; nil keeps the current value
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
        self.productType = sourceRevision.productType
        self.systemVersion = sourceRevision.systemVersion
        self.operatingSystem = OperatingSystem(
            version: sourceRevision.operatingSystemVersion
        )
    }

    /// Creates the **SourceRevision** from its fields
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

    /// A copy with the given fields replaced; nil keeps the current value
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
        return HKSourceRevision(
            source: try source.asOriginal(),
            version: version,
            productType: productType,
            operatingSystemVersion: operatingSystem.original
        )
    }
}
// MARK: - Payload
extension SourceRevision.OperatingSystem: Payload {
    /**
     Makes a **SourceRevision.OperatingSystem** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(
        from dictionary: [String: Any]
    ) throws -> SourceRevision.OperatingSystem {
        guard
            let majorVersion = dictionary.int("majorVersion"),
            let minorVersion = dictionary.int("minorVersion"),
            let patchVersion = dictionary.int("patchVersion")
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
    /**
     Makes a **SourceRevision** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
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
