//
//  Extensions+HKHealthConceptIdentifier.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

@available(iOS 26.0, watchOS 26.0, *)
extension HKHealthConceptIdentifier {
    /// The opaque identifier, securely archived and base64 encoded so it can travel in a payload
    var asArchivedString: String? {
        return (try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true))?
            .base64EncodedString()
    }

    static func make(fromArchived string: String) throws -> HKHealthConceptIdentifier {
        guard
            let data = Data(base64Encoded: string),
            let identifier = try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: HKHealthConceptIdentifier.self,
                from: data
            )
        else {
            throw HealthKitError.invalidValue("Invalid medication concept identifier: \(string)")
        }
        return identifier
    }
}
