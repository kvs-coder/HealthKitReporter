//
//  ScoredAssessment.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/**
 GAD-7 or PHQ-9 questionnaire, told apart by **identifier**.
 Answers are 0 not at all, 1 several days, 2 more than half the days, 3 nearly every day,
 and 4 prefer not to answer (PHQ-9 question 9 only).
 Risk follows **HKGAD7Assessment.Risk** / **HKPHQ9Assessment.Risk**
 */
@available(iOS 18.0, watchOS 11.0, *)
public struct ScoredAssessment: Identifiable, Sample {
    public struct Harmonized: Codable {
        public let answers: [Int]
        /// read only, computed by HealthKit
        public let score: Int?
        /// read only, computed by HealthKit
        public let risk: Int?
        public let metadata: Metadata?

        public init(answers: [Int], score: Int?, risk: Int?, metadata: Metadata?) {
            self.answers = answers
            self.score = score
            self.risk = risk
            self.metadata = metadata
        }

        public func copyWith(
            answers: [Int]? = nil,
            score: Int? = nil,
            risk: Int? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                answers: answers ?? self.answers,
                score: score ?? self.score,
                risk: risk ?? self.risk,
                metadata: metadata ?? self.metadata
            )
        }
    }

    public let uuid: String
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: Harmonized

    public init(
        uuid: String = UUID().uuidString,
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        device: Device?,
        sourceRevision: SourceRevision,
        harmonized: Harmonized
    ) {
        self.uuid = uuid
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.harmonized = harmonized
    }

    init(assessment: HKScoredAssessment) throws {
        self.uuid = assessment.uuid.uuidString
        self.identifier = assessment.sampleType.identifier
        self.startTimestamp = assessment.startDate.timeIntervalSince1970
        self.endTimestamp = assessment.endDate.timeIntervalSince1970
        self.device = Device(device: assessment.device)
        self.sourceRevision = SourceRevision(sourceRevision: assessment.sourceRevision)
        let metadata = assessment.metadata?.asMetadata
        switch assessment {
        case let gad7 as HKGAD7Assessment:
            self.harmonized = Harmonized(
                answers: gad7.answers.map(\.rawValue),
                score: gad7.score,
                risk: gad7.risk.rawValue,
                metadata: metadata
            )
        case let phq9 as HKPHQ9Assessment:
            self.harmonized = Harmonized(
                answers: phq9.answers.map(\.rawValue),
                score: phq9.score,
                risk: phq9.risk.rawValue,
                metadata: metadata
            )
        default:
            throw HealthKitError.invalidType("Unknown scored assessment: \(assessment.sampleType.identifier)")
        }
    }

    public func copyWith(
        uuid: String? = nil,
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        harmonized: Harmonized? = nil
    ) -> ScoredAssessment {
        return ScoredAssessment(
            uuid: uuid ?? self.uuid,
            identifier: identifier ?? self.identifier,
            startTimestamp: startTimestamp ?? self.startTimestamp,
            endTimestamp: endTimestamp ?? self.endTimestamp,
            device: device ?? self.device,
            sourceRevision: sourceRevision ?? self.sourceRevision,
            harmonized: harmonized ?? self.harmonized
        )
    }
}
// MARK: - Original
@available(iOS 18.0, watchOS 11.0, *)
extension ScoredAssessment: Original {
    /// HealthKit needs exactly 7 (GAD-7) or 9 (PHQ-9) answers within the questionnaire's scale
    func asOriginal() throws -> HKScoredAssessment {
        let answers = harmonized.answers
        let metadata = try harmonized.metadata?.asOriginal()
        switch identifier.objectType as? ScoredAssessmentType {
        case .gad7:
            guard answers.count == 7, answers.allSatisfy({ (0...3).contains($0) }) else {
                throw HealthKitError.invalidValue("GAD-7 needs 7 answers from 0 to 3: \(answers)")
            }
            return HKGAD7Assessment(
                date: startTimestamp.asDate,
                answers: answers.compactMap { HKGAD7Assessment.Answer(rawValue: $0) },
                metadata: metadata
            )
        case .phq9:
            guard
                answers.count == 9,
                answers.dropLast().allSatisfy({ (0...3).contains($0) }),
                answers.last.map({ (0...4).contains($0) }) == true
            else {
                throw HealthKitError.invalidValue(
                    "PHQ-9 needs 9 answers from 0 to 3, the last one up to 4: \(answers)"
                )
            }
            return HKPHQ9Assessment(
                date: startTimestamp.asDate,
                answers: answers.compactMap { HKPHQ9Assessment.Answer(rawValue: $0) },
                metadata: metadata
            )
        case nil:
            throw HealthKitError.invalidType(
                "Scored assessment identifier: \(identifier) could not be formatted"
            )
        }
    }
}
// MARK: - Payload
@available(iOS 18.0, watchOS 11.0, *)
extension ScoredAssessment: Payload {
    public static func make(from dictionary: [String: Any]) throws -> ScoredAssessment {
        guard
            let identifier = dictionary["identifier"] as? String,
            let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
            let endTimestamp = dictionary["endTimestamp"] as? NSNumber,
            let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let device = dictionary["device"] as? [String: Any]
        return ScoredAssessment(
            uuid: dictionary.payloadUUID,
            identifier: identifier,
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: Double(truncating: endTimestamp),
            device: try device.map(Device.make),
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
// MARK: - Factory
@available(iOS 18.0, watchOS 11.0, *)
extension ScoredAssessment {
    static func collect(results: [HKSample]) -> [ScoredAssessment] {
        return results
            .compactMap { $0 as? HKScoredAssessment }
            .compactMap { try? ScoredAssessment(assessment: $0) }
    }
}
// MARK: - Harmonized: Payload
@available(iOS 18.0, watchOS 11.0, *)
extension ScoredAssessment.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> ScoredAssessment.Harmonized {
        guard let answers = dictionary["answers"] as? [NSNumber] else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let metadata = dictionary["metadata"] as? [String: Any]
        return ScoredAssessment.Harmonized(
            answers: answers.map(\.intValue),
            score: (dictionary["score"] as? NSNumber)?.intValue,
            risk: (dictionary["risk"] as? NSNumber)?.intValue,
            metadata: try metadata.map(Metadata.make)
        )
    }
}
