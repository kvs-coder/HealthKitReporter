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
     - Parameter type: **QuantityType** type
     - Parameter unit: **String** unit compatible with the type
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter separateBySource: **Bool** also compute **Statistics.sourceStatistics**. False by default
     - Parameter completionHandler: returns a block with statistics
     - Throws: HealthKitError.invalidType, HealthKitError.invalidValue on a malformed or incompatible unit
     */
    public func statisticsQuery(
        type: QuantityType,
        unit: String,
        predicate: NSPredicate? = .allSamples,
        separateBySource: Bool = false,
        completionHandler: @escaping StatisticsCompletionHandler
    ) throws -> QueryHandle {
        guard let quantityType = type.hkObjectType as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKQuantityType"
            )
        }
        let hkUnit = try quantityType.compatibleUnit(from: unit)
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: quantityType.statisticsOptions(separateBySource: separateBySource)
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
                    unit: hkUnit
                )
                completionHandler(statistics, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        return QueryHandle(query)
    }
    /**
     Queries statistics collection.
     - Parameter type: **QuantityType** types
     - Parameter unit: **String** unit compatible with the type
     - Parameter quantitySamplePredicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter anchorDate: **Date** anchor date
     - Parameter enumerateFrom: **Date** start enumeration date
     - Parameter enumerateTo: **Date** end enumeration date
     - Parameter intervalComponents: **DateComponents** components to set the frequency
     of a collection appearing
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     Every update enumerates the whole range again.
     - Parameter separateBySource: **Bool** also compute **Statistics.sourceStatistics**. False by default
     - Parameter enumerationBlock: returns a block with statistics on every iteration, without an end signal.
     Use the **StatisticsCollectionResultsHandler** variant to receive whole batches
     - Throws: HealthKitError.invalidType, HealthKitError.invalidValue on a malformed or incompatible unit
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
        separateBySource: Bool = false,
        enumerationBlock: @escaping StatisticsCompletionHandler
    ) throws -> QueryHandle {
        guard let quantityType = type.hkObjectType as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKQuantityType"
            )
        }
        let hkUnit = try quantityType.compatibleUnit(from: unit)
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
                        unit: hkUnit
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
            options: quantityType.statisticsOptions(separateBySource: separateBySource),
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
        return QueryHandle(query)
    }
    /**
     Queries statistics collection, delivering whole batches.
     The handler gets every interval from **enumerateFrom** to **enumerateTo** once,
     then, with **monitorUpdates**, only the intervals each update changed, also after **enumerateTo**.
     - Parameter type: **QuantityType** types
     - Parameter unit: **String** unit compatible with the type
     - Parameter quantitySamplePredicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter anchorDate: **Date** anchor date
     - Parameter enumerateFrom: **Date** start enumeration date
     - Parameter enumerateTo: **Date** end enumeration date (optional). Now by default
     - Parameter intervalComponents: **DateComponents** components to set the frequency
     of a collection appearing
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     - Parameter separateBySource: **Bool** also compute **Statistics.sourceStatistics**. False by default
     - Parameter resultsHandler: returns one batch per initial result and per update
     - Throws: HealthKitError.invalidType, HealthKitError.invalidValue on a malformed or incompatible unit
     */
    public func statisticsCollectionQuery( // swiftlint:disable:this function_parameter_count
        type: QuantityType,
        unit: String,
        quantitySamplePredicate: NSPredicate? = .allSamples,
        anchorDate: Date,
        enumerateFrom: Date,
        enumerateTo: Date? = nil,
        intervalComponents: DateComponents,
        monitorUpdates: Bool = false,
        separateBySource: Bool = false,
        resultsHandler: @escaping StatisticsCollectionResultsHandler
    ) throws -> QueryHandle {
        guard let quantityType = type.hkObjectType as? HKQuantityType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKQuantityType"
            )
        }
        let hkUnit = try quantityType.compatibleUnit(from: unit)
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: quantitySamplePredicate,
            options: quantityType.statisticsOptions(separateBySource: separateBySource),
            anchorDate: anchorDate,
            intervalComponents: intervalComponents
        )
        query.initialResultsHandler = { (_, collection, error) in
            guard error == nil, let collection = collection else {
                resultsHandler([], error)
                return
            }
            let batch = collection.statistics().filter {
                $0.endDate > enumerateFrom && $0.startDate < (enumerateTo ?? Date())
            }
            resultsHandler(batch.compactMap { try? Statistics(statistics: $0, unit: hkUnit) }, nil)
        }
        if monitorUpdates {
            query.statisticsUpdateHandler = { (_, statistics, _, error) in
                guard error == nil else {
                    resultsHandler([], error)
                    return
                }
                guard let statistics = statistics else {
                    return
                }
                resultsHandler([try? Statistics(statistics: statistics, unit: hkUnit)].compactMap { $0 }, nil)
            }
        }
        return QueryHandle(query)
    }
}
