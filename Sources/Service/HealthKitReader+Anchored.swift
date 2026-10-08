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
        let resultsHandler: AnchoredObjectQueryHandler = { (query, data, deletedData, anchor, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler(query, [], [], anchor, error)
                return
            }
            var samples = [Sample]()
            for element in result {
                do {
                    let sample = try element.parsed()
                    samples.append(sample)
                } catch {
                    continue
                }
            }
            let deletedObjects = DeletedObject.collect(deletedObjects: deletedData)
            completionHandler(
                query,
                samples,
                deletedObjects,
                anchor,
                nil
            )
        }
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
}
