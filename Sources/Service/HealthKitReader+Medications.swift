//
//  HealthKitReader+Medications.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

// MARK: - Medications
@available(iOS 26.0, watchOS 26.0, *)
extension HealthKitReader {
    /**
     Queries logged medication doses.
     - Requires: per-object read authorization, see **HealthKitManager.requestPerObjectReadAuthorization**
     - Parameter medicationConceptIdentifier: **String** limits the doses to one medication (optional),
     see **UserAnnotatedMedication.Concept.identifier**
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with dose events
     - Throws: HealthKitError.invalidType, HealthKitError.invalidValue on an invalid medication identifier
     */
    public func medicationDoseEventQuery(
        medicationConceptIdentifier: String? = nil,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping MedicationDoseEventResultsHandler
    ) throws -> SampleQuery {
        var predicates = [predicate].compactMap { $0 }
        if let medicationConceptIdentifier = medicationConceptIdentifier {
            predicates.append(
                HKQuery.predicateForMedicationDoseEvent(
                    medicationConceptIdentifier: try HKHealthConceptIdentifier.make(
                        fromArchived: medicationConceptIdentifier
                    )
                )
            )
        }
        return try typedSampleQuery(
            type: MedicationType.medicationDoseEvent,
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates),
            sortDescriptors: sortDescriptors,
            limit: limit,
            collect: MedicationDoseEvent.collect,
            resultsHandler: resultsHandler
        )
    }
    /**
     Queries the medications the user tracks.
     - Requires: per-object read authorization, see **HealthKitManager.requestPerObjectReadAuthorization**
     - Parameter predicate: **NSPredicate** predicate (optional). nil by default
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with every medication once the query is done
     */
    public func userAnnotatedMedicationQuery(
        predicate: NSPredicate? = nil,
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping UserAnnotatedMedicationResultsHandler
    ) -> UserAnnotatedMedicationQuery {
        var medications = [UserAnnotatedMedication]()
        return HKUserAnnotatedMedicationQuery(
            predicate: predicate,
            limit: limit
        ) { (_, medication, done, error) in
            if let error = error {
                resultsHandler([], error)
                return
            }
            if let medication = medication {
                medications.append(UserAnnotatedMedication(userAnnotatedMedication: medication))
            }
            if done {
                resultsHandler(medications, nil)
            }
        }
    }
}
