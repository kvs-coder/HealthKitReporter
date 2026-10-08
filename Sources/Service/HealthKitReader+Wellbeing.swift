//
//  HealthKitReader+Wellbeing.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

// MARK: - Wellbeing
extension HealthKitReader {
    /**
     Queries audiograms.
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with audiograms
     - Throws: HealthKitError.invalidType
     */
    public func audiogramQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping AudiogramResultsHandler
    ) throws -> SampleQuery {
        return try typedSampleQuery(
            type: AudiogramType.audiogram,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            collect: Audiogram.collect,
            resultsHandler: resultsHandler
        )
    }
    /**
     Queries logged emotions and moods.
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with states of mind
     - Throws: HealthKitError.invalidType
     */
    @available(iOS 18.0, watchOS 11.0, *)
    public func stateOfMindQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping StateOfMindResultsHandler
    ) throws -> SampleQuery {
        return try typedSampleQuery(
            type: StateOfMindType.stateOfMind,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            collect: StateOfMind.collect,
            resultsHandler: resultsHandler
        )
    }
    /**
     Queries GAD-7 or PHQ-9 assessments.
     - Parameter type: **ScoredAssessmentType** type
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with assessments
     - Throws: HealthKitError.invalidType
     */
    @available(iOS 18.0, watchOS 11.0, *)
    public func scoredAssessmentQuery(
        type: ScoredAssessmentType,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping ScoredAssessmentResultsHandler
    ) throws -> SampleQuery {
        return try typedSampleQuery(
            type: type,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit,
            collect: ScoredAssessment.collect,
            resultsHandler: resultsHandler
        )
    }
}
