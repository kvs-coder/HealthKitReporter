//
//  HealthKitReader+Anchored.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

// MARK: - Anchored
extension HealthKitReader {
    /**
     Queries objects (with anchors).
     - Parameter type: **SampleType** types
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter anchor: **Anchor** anchor of a previous run (optional). From the beginning by default
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     Requires **limit** to be HKObjectQueryNoLimit.
     - Parameter completionHandler: returns a block with samples. On an error, no samples and the **anchor**
     passed in; HealthKitError.parsingFailed when a sample can't be parsed
     - Throws: HealthKitError.invalidType, HealthKitError.invalidOption,
     HealthKitError.invalidValue for anchor data that doesn't hold a HealthKit anchor
     */
    public func anchoredObjectQuery(
        type: SampleType,
        predicate: NSPredicate? = .allSamples,
        anchor: Anchor? = nil,
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping AnchoredResultsHandler
    ) throws -> QueryHandle {
        guard let sampleType = type.hkObjectType as? HKSampleType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKSampleType"
            )
        }
        guard !monitorUpdates || limit == HKObjectQueryNoLimit else {
            throw HealthKitError.invalidOption("monitorUpdates requires limit HKObjectQueryNoLimit: \(limit)")
        }
        let resultsHandler = anchoredResultsHandler(anchor: anchor, completionHandler)
        let query = HKAnchoredObjectQuery(
            type: sampleType,
            predicate: predicate,
            anchor: try anchor?.asOriginal(),
            limit: limit,
            resultsHandler: resultsHandler
        )
        if monitorUpdates {
            query.updateHandler = resultsHandler
        }
        return QueryHandle(query)
    }
    /**
     Queries sources.
     - Parameter type: **SampleType** types
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter completionHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func sourceQuery(
        type: SampleType,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping SourceCompletionHandler
    ) throws -> QueryHandle {
        guard let sampleType = type.hkObjectType as? HKSampleType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKSampleType"
            )
        }
        let query = HKSourceQuery(
            sampleType: sampleType,
            samplePredicate: predicate
        ) { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler([], error)
                return
            }
            let sources = result.map { Source(source: $0) }
            completionHandler(sources, nil)
        }
        return QueryHandle(query)
    }
    /**
     Queries objects of several types (with anchors).
     - Parameter descriptors: **QueryDescriptor** types and predicates
     - Parameter anchor: **Anchor** anchor of a previous run (optional). From the beginning by default
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     Requires **limit** to be HKObjectQueryNoLimit.
     - Parameter completionHandler: returns a block with samples of every type. On an error, no samples
     and the **anchor** passed in; HealthKitError.parsingFailed when a sample can't be parsed
     - Throws: HealthKitError.invalidType, HealthKitError.invalidOption,
     HealthKitError.invalidValue for anchor data that doesn't hold a HealthKit anchor
     */
    public func anchoredObjectQuery(
        descriptors: [QueryDescriptor],
        anchor: Anchor? = nil,
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping AnchoredResultsHandler
    ) throws -> QueryHandle {
        guard !monitorUpdates || limit == HKObjectQueryNoLimit else {
            throw HealthKitError.invalidOption("monitorUpdates requires limit HKObjectQueryNoLimit: \(limit)")
        }
        let resultsHandler = anchoredResultsHandler(anchor: anchor, completionHandler)
        let query = HKAnchoredObjectQuery(
            queryDescriptors: try descriptors.map { try $0.asOriginal() },
            anchor: try anchor?.asOriginal(),
            limit: limit,
            resultsHandler: resultsHandler
        )
        if monitorUpdates {
            query.updateHandler = resultsHandler
        }
        return QueryHandle(query)
    }

    /// Hands back the caller's **anchor** on an error, so a sample that fails to parse is delivered again
    private func anchoredResultsHandler(
        anchor callerAnchor: Anchor?,
        _ completionHandler: @escaping AnchoredResultsHandler
    ) -> AnchoredObjectQueryHandler {
        return { (query, data, deletedData, anchor, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler(QueryHandle(query), [], [], callerAnchor, error)
                return
            }
            do {
                completionHandler(
                    QueryHandle(query),
                    try result.parsedSamples(),
                    DeletedObject.collect(deletedObjects: deletedData),
                    Anchor(anchor),
                    nil
                )
            } catch {
                completionHandler(QueryHandle(query), [], [], callerAnchor, error)
            }
        }
    }
}
