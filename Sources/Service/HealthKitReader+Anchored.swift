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
     - Parameter anchor: **HKQueryAnchor** anchor. HKAnchoredObjectQueryNoAnchor by default
     - Parameter limit: **Int** anchor. HKObjectQueryNoLimit by default
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     Requires **limit** to be HKObjectQueryNoLimit.
     - Parameter completionHandler: returns a block with samples
     - Throws: HealthKitError.invalidType, HealthKitError.invalidOption
     */
    public func anchoredObjectQuery(
        type: SampleType,
        predicate: NSPredicate? = .allSamples,
        anchor: Anchor? = HKQueryAnchor(
            fromValue: Int(HKAnchoredObjectQueryNoAnchor)
        ),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping AnchoredResultsHandler
    ) throws -> AnchoredObjectQuery {
        guard let sampleType = type.original as? HKSampleType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKSampleType"
            )
        }
        guard !monitorUpdates || limit == HKObjectQueryNoLimit else {
            throw HealthKitError.invalidOption("monitorUpdates requires limit HKObjectQueryNoLimit: \(limit)")
        }
        let resultsHandler = anchoredResultsHandler(completionHandler)
        let query = HKAnchoredObjectQuery(
            type: sampleType,
            predicate: predicate,
            anchor: anchor,
            limit: limit,
            resultsHandler: resultsHandler
        )
        if monitorUpdates {
            query.updateHandler = resultsHandler
        }
        return query
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
    ) throws -> SourceQuery {
        guard let sampleType = type.original as? HKSampleType else {
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
        return query
    }
    /**
     Queries objects of several types (with anchors).
     - Parameter descriptors: **QueryDescriptor** types and predicates
     - Parameter anchor: **HKQueryAnchor** anchor. HKAnchoredObjectQueryNoAnchor by default
     - Parameter limit: **Int** anchor. HKObjectQueryNoLimit by default
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     Requires **limit** to be HKObjectQueryNoLimit.
     - Parameter completionHandler: returns a block with samples of every type
     - Throws: HealthKitError.invalidType, HealthKitError.invalidOption
     */
    public func anchoredObjectQuery(
        descriptors: [QueryDescriptor],
        anchor: Anchor? = HKQueryAnchor(
            fromValue: Int(HKAnchoredObjectQueryNoAnchor)
        ),
        limit: Int = HKObjectQueryNoLimit,
        monitorUpdates: Bool = false,
        completionHandler: @escaping AnchoredResultsHandler
    ) throws -> AnchoredObjectQuery {
        guard !monitorUpdates || limit == HKObjectQueryNoLimit else {
            throw HealthKitError.invalidOption("monitorUpdates requires limit HKObjectQueryNoLimit: \(limit)")
        }
        let resultsHandler = anchoredResultsHandler(completionHandler)
        let query = HKAnchoredObjectQuery(
            queryDescriptors: try descriptors.map { try $0.asOriginal() },
            anchor: anchor,
            limit: limit,
            resultsHandler: resultsHandler
        )
        if monitorUpdates {
            query.updateHandler = resultsHandler
        }
        return query
    }

    private func anchoredResultsHandler(
        _ completionHandler: @escaping AnchoredResultsHandler
    ) -> AnchoredObjectQueryHandler {
        return { (query, data, deletedData, anchor, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler(query, [], [], anchor, error)
                return
            }
            completionHandler(
                query,
                result.compactMap { try? $0.parsed() },
                DeletedObject.collect(deletedObjects: deletedData),
                anchor,
                nil
            )
        }
    }
}
