//
//  Statistics.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import HealthKit

public struct Statistics: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let summary: Double?
        public let average: Double?
        public let recent: Double?
        public let min: Double?
        public let max: Double?
        public let unit: String
        /// seconds covered by data
        public let duration: Double?

        public init(
            summary: Double?,
            average: Double?,
            recent: Double?,
            min: Double?,
            max: Double?,
            unit: String,
            duration: Double? = nil
        ) {
            self.summary = summary
            self.average = average
            self.recent = recent
            self.min = min
            self.max = max
            self.unit = unit
            self.duration = duration
        }

        public func copyWith(
            summary: Double? = nil,
            average: Double? = nil,
            recent: Double? = nil,
            min: Double? = nil,
            max: Double? = nil,
            unit: String? = nil,
            duration: Double? = nil
        ) -> Harmonized {
            return Harmonized(
                summary: summary ?? self.summary,
                average: average ?? self.average,
                recent: recent ?? self.recent,
                min: min ?? self.min,
                max: max ?? self.max,
                unit: unit ?? self.unit,
                duration: duration ?? self.duration
            )
        }
    }
    /// Statistics of one source, when the query separates by source
    public struct SourceStatistics: Codable {
        public let source: Source
        public let harmonized: Harmonized

        public init(source: Source, harmonized: Harmonized) {
            self.source = source
            self.harmonized = harmonized
        }
    }

    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let harmonized: Harmonized
    public let sources: [Source]
    /// per-source statistics; nil unless the query separates by source
    public let sourceStatistics: [SourceStatistics]?

    init(statistics: HKStatistics, unit: HKUnit) throws {
        self.identifier = statistics.quantityType.identifier
        self.startTimestamp = statistics.startDate.timeIntervalSince1970
        self.endTimestamp = statistics.endDate.timeIntervalSince1970
        self.sources = statistics.sources?.map { Source(source: $0) } ?? []
        self.harmonized = statistics.harmonized(unit: unit)
        self.sourceStatistics = statistics.sources?.map {
            SourceStatistics(
                source: Source(source: $0),
                harmonized: statistics.harmonized(unit: unit, for: $0)
            )
        }
    }
    init(statistics: HKStatistics) throws {
        try self.init(statistics: statistics, unit: try statistics.quantityType.siUnit)
    }

    private init(
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        harmonized: Harmonized,
        sources: [Source],
        sourceStatistics: [SourceStatistics]?
    ) {
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.harmonized = harmonized
        self.sources = sources
        self.sourceStatistics = sourceStatistics
    }

    public func copyWith(
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        harmonized: Harmonized? = nil,
        sources: [Source]? = nil,
        sourceStatistics: [SourceStatistics]? = nil
    ) -> Statistics {
        return Statistics(
            identifier: identifier ?? self.identifier,
            startTimestamp: startTimestamp ?? self.startTimestamp,
            endTimestamp: endTimestamp ?? self.endTimestamp,
            harmonized: harmonized ?? self.harmonized,
            sources: sources ?? self.sources,
            sourceStatistics: sourceStatistics ?? self.sourceStatistics
        )
    }
}
// MARK: - UnitConvertable
extension Statistics: UnitConvertable {
    public func converted(to unit: String) throws -> Statistics {
        guard harmonized.unit != unit else {
            return self
        }
        guard let type = identifier.objectType?.hkObjectType as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "Statistics type identifier: \(identifier) could not be formatted"
            )
        }
        let fromUnit = try type.compatibleUnit(from: harmonized.unit)
        let toUnit = try type.compatibleUnit(from: unit)
        let convert: (Harmonized) -> Harmonized = { harmonized in
            let value: (Double?) -> Double? = { value in
                value.map { HKQuantity(unit: fromUnit, doubleValue: $0).doubleValue(for: toUnit) }
            }
            return Harmonized(
                summary: value(harmonized.summary),
                average: value(harmonized.average),
                recent: value(harmonized.recent),
                min: value(harmonized.min),
                max: value(harmonized.max),
                unit: unit,
                duration: harmonized.duration
            )
        }
        return copyWith(
            harmonized: convert(harmonized),
            sourceStatistics: sourceStatistics?.map {
                SourceStatistics(source: $0.source, harmonized: convert($0.harmonized))
            }
        )
    }
}
