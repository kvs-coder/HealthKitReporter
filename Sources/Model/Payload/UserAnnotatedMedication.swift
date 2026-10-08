//
//  UserAnnotatedMedication.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// Medication the user tracks in the Health app. Read only
@available(iOS 26.0, watchOS 26.0, *)
public struct UserAnnotatedMedication: Codable {
    /// **Coding** one code of a medication concept, e.g. RxNorm
    public struct Coding: Codable {
        public let system: String
        public let version: String?
        public let code: String

        /// Creates the **Coding** from its fields
        public init(system: String, version: String?, code: String) {
            self.system = system
            self.version = version
            self.code = code
        }
    }

    /// **Concept** the medication a user tracks, with its codings
    public struct Concept: Codable {
        /// opaque identifier, securely archived and base64 encoded;
        /// pass it to **HealthKitReader.medicationDoseEventQuery** to read this medication's doses
        public let identifier: String
        public let domain: String
        public let displayText: String
        /// e.g. tablet, capsule, liquid
        public let generalForm: String
        public let relatedCodings: [Coding]

        /// Creates the **Concept** from its fields
        public init(
            identifier: String,
            domain: String,
            displayText: String,
            generalForm: String,
            relatedCodings: [Coding]
        ) {
            self.identifier = identifier
            self.domain = domain
            self.displayText = displayText
            self.generalForm = generalForm
            self.relatedCodings = relatedCodings
        }
    }

    public let nickname: String?
    public let isArchived: Bool
    public let hasSchedule: Bool
    public let medication: Concept

    /// Creates the **UserAnnotatedMedication** from its fields
    public init(nickname: String?, isArchived: Bool, hasSchedule: Bool, medication: Concept) {
        self.nickname = nickname
        self.isArchived = isArchived
        self.hasSchedule = hasSchedule
        self.medication = medication
    }

    init(userAnnotatedMedication: HKUserAnnotatedMedication) {
        let concept = userAnnotatedMedication.medication
        self.nickname = userAnnotatedMedication.nickname
        self.isArchived = userAnnotatedMedication.isArchived
        self.hasSchedule = userAnnotatedMedication.hasSchedule
        self.medication = Concept(
            identifier: concept.identifier.asArchivedString ?? String(),
            domain: concept.identifier.domain.rawValue,
            displayText: concept.displayText,
            generalForm: concept.generalForm.rawValue,
            relatedCodings: concept.relatedCodings
                .map { Coding(system: $0.system, version: $0.version, code: $0.code) }
                .sorted { ($0.system, $0.code) < ($1.system, $1.code) }
        )
    }
}
// MARK: - Payload
@available(iOS 26.0, watchOS 26.0, *)
extension UserAnnotatedMedication: Payload {
    /**
     Makes an **UserAnnotatedMedication** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> UserAnnotatedMedication {
        guard
            let isArchived = dictionary.bool("isArchived"),
            let hasSchedule = dictionary.bool("hasSchedule"),
            let medication = dictionary["medication"] as? [String: Any],
            let identifier = medication["identifier"] as? String,
            let domain = medication["domain"] as? String,
            let displayText = medication["displayText"] as? String,
            let generalForm = medication["generalForm"] as? String,
            let codings = medication["relatedCodings"] as? [[String: Any]]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return UserAnnotatedMedication(
            nickname: dictionary["nickname"] as? String,
            isArchived: isArchived,
            hasSchedule: hasSchedule,
            medication: Concept(
                identifier: identifier,
                domain: domain,
                displayText: displayText,
                generalForm: generalForm,
                relatedCodings: try codings.map { coding in
                    guard
                        let system = coding["system"] as? String,
                        let code = coding["code"] as? String
                    else {
                        throw HealthKitError.invalidValue("Invalid coding: \(coding)")
                    }
                    return Coding(system: system, version: coding["version"] as? String, code: code)
                }
            )
        )
    }
}
