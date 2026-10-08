//
//  HealthKitReader+Statistics.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

// MARK: - Statistics
extension HealthKitReader {
    /**
     Queries statistics.
     - Parameter type: **ObjectType** types
     - Parameter unit: **String** unit
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter completionHandler: returns a block with statistics
     - Throws: HealthKitError.invalidType
     */
    public func statisticsQuery(
        type: QuantityType,
        unit: String,
        predicate: NSPredicate? = .allSamples,
        completionHandler: @escaping StatisticsCompletionHandler
    ) throws -> StatisticsQuery {
        guard let quantityType = type.original as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKQuantityType"
            )
        }
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: quantityType.statisticsOptions
        ) { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler(nil, error)
                return
            }
            do {
                let statistics = try Statistics(
                    statistics: result,
                    unit: HKUnit.init(from: unit)
                )
                completionHandler(statistics, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        return query
    }
    /**
     Queries statistics collection.
     - Parameter type: **QuantityType** types
     - Parameter unit: **String** unit
     - Parameter quantitySamplePredicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter anchorDate: **Date** anchor date
     - Parameter enumerateFrom: **Date** start enumeration date
     - Parameter enumerateTo: **Date** end enumeration date
     - Parameter intervalComponents: **DateComponents** components to set the frequency
     of a collection appearing
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     - Parameter enumerationBlock: returns a block with statistics on every iteration
     - Throws: HealthKitError.invalidType
     */
    public func statisticsCollectionQuery( // swiftlint:disable:this function_parameter_count
        type: QuantityType,
        unit: String,
        quantitySamplePredicate: NSPredicate? = .allSamples,
        anchorDate: Date,
        enumerateFrom: Date,
        enumerateTo: Date,
        intervalComponents: DateComponents,
        monitorUpdates: Bool = false,
        enumerationBlock: @escaping StatisticsCompletionHandler
    ) throws -> StatisticsCollectionQuery {
        guard let quantityType = type.original as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKQuantityType"
            )
        }
        let resultsHandler: StatisticsCollectionHandler = { (data, error) in
            guard
                error == nil,
                let result = data
            else {
                enumerationBlock(nil, error)
                return
            }
            result.enumerateStatistics(
                from: enumerateFrom,
                to: enumerateTo
            ) { (data, _) in
                do {
                    let statistics = try Statistics(
                        statistics: data,
                        unit: HKUnit.init(from: unit)
                    )
                    enumerationBlock(statistics, nil)
                } catch {
                    enumerationBlock(nil, error)
                }
            }
        }
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: quantitySamplePredicate,
            options: quantityType.statisticsOptions,
            anchorDate: anchorDate,
            intervalComponents: intervalComponents
        )
        query.initialResultsHandler = { (_, result, error) in
            resultsHandler(result, error)
        }
        if monitorUpdates {
            query.statisticsUpdateHandler = { (_, _, result, error) in
                resultsHandler(result, error)
            }
        }
        return query
    }
}
