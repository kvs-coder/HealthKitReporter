//
//  HealthKitReader.swift
//  HealthKitReader
//
//  Created by Victor on 23.09.20.
//

import HealthKit

typealias ActivitySummaryUpdateHandler = (
    HKActivitySummaryQuery, [HKActivitySummary]?, Error?
) -> Void
typealias HKStatisticsCollectionHandler = (
    HKStatisticsCollection?, Error?
) -> Void
typealias AnchoredObjectQueryHandler = (
    HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?
) -> Void
typealias StatisticsCollectionHandler = (
    HKStatisticsCollection?, Error?
) -> Void

/// **HealthKitReader** class for HK reading operations
public class HealthKitReader {
    let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    /**
     Gets user's characteristics.
     A characteristic that is not authorized or not set is nil.
     - Returns: **Characteristics** characteristics
     */
    public func characteristics() -> Characteristic {
        let biologicalSex = try? healthStore.biologicalSex()
        let bloodType = try? healthStore.bloodType()
        let fitzpatrickSkinType = try? healthStore.fitzpatrickSkinType()
        let birthday = try? healthStore.dateOfBirthComponents()
        let wheelchairUse = try? healthStore.wheelchairUse()
        let activityMoveMode = try? healthStore.activityMoveMode()
        return Characteristic(
            biologicalSex: biologicalSex,
            birthday: birthday,
            bloodType: bloodType,
            fitzpatrickSkinType: fitzpatrickSkinType,
            wheelchairUse: wheelchairUse,
            activityMoveMode: activityMoveMode
        )
    }
    /**
     Queries quantity types.
     - Parameter type: **QuantityType** types
     - Parameter unit: **String** unit compatible with the type
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType, HealthKitError.invalidValue on a malformed or incompatible unit
     */
    public func quantityQuery(
        type: QuantityType,
        unit: String,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping QuantityResultsHandler
    ) throws -> QueryHandle {
        guard let quantityType = type.hkObjectType as? HKQuantityType else {
            throw HealthKitError.invalidType("Invalid HKQuantityType: \(type)")
        }
        let hkUnit = try quantityType.compatibleUnit(from: unit)
        let query = HKSampleQuery(
            sampleType: quantityType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (query, data, error) in
            guard
                error == nil,
                let results = data
            else {
                resultsHandler([], error)
                return
            }
            let samples = Quantity.collect(
                results: results,
                unit: hkUnit
            )
            resultsHandler(samples, nil)
        }
        return QueryHandle(query)
    }
    /**
     Queries category types.
     - Parameter type: **CategoryType** types
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func categoryQuery(
        type: CategoryType,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping CategoryResultsHandler
    ) throws -> QueryHandle {
        guard let sampleType = type.hkObjectType as? HKCategoryType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKCategoryType")
        }
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (_, data, error) in
            guard
                error == nil,
                let results = data
            else {
                resultsHandler([], error)
                return
            }
            let samples = Category.collect(results: results)
            resultsHandler(samples, nil)
        }
        return QueryHandle(query)
    }
    /**
     Queries workouts.
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func workoutQuery(
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping WorkoutResultsHandler
    ) throws -> QueryHandle {
        let workoutType = WorkoutType.workoutType
        guard let type = workoutType.hkObjectType as? HKWorkoutType else {
            throw HealthKitError.invalidType(
                "\(workoutType) can not be represented as HKWorkoutType"
            )
        }
        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (query, data, error) in
            guard
                error == nil,
                let results = data
            else {
                resultsHandler([], error)
                return
            }
            let samples = Workout.collect(
                results: results
            )
            resultsHandler(samples, nil)
        }
        return QueryHandle(query)
    }
    /**
     Queries samples of any type. Quantities come in SI units; heartbeat series, workout routes and ECGs
     come without their measurements, which their own queries deliver
     - Parameter type: **SampleType** types
     - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors. By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples
     - Throws: HealthKitError.invalidType
     */
    public func sampleQuery(
        type: SampleType,
        predicate: NSPredicate? = .allSamples,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping SampleResultsHandler
    ) throws -> QueryHandle {
        guard let sampleType = type.hkObjectType as? HKSampleType else {
            throw HealthKitError.invalidType(
                "\(type) can not be represented as HKSampleType"
            )
        }
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (query, data, error) in
            guard
                error == nil,
                let result = data
            else {
                resultsHandler(
                    QueryHandle(query),
                    [],
                    error
                )
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
            resultsHandler(
                QueryHandle(query),
                samples,
                nil
            )
        }
        return QueryHandle(query)
    }
    /**
     Queries samples of several types at once.
     - Parameter descriptors: **QueryDescriptor** types and predicates
     - Parameter sortDescriptors: array of **NSSortDescriptor** sort descriptors.
     By default sorting by startData without ascending
     - Parameter limit: **Int** limit of the elements. HKObjectQueryNoLimit by default
     - Parameter resultsHandler: returns a block with samples of every type
     - Throws: HealthKitError.invalidType
     */
    public func sampleQuery(
        descriptors: [QueryDescriptor],
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
        ],
        limit: Int = HKObjectQueryNoLimit,
        resultsHandler: @escaping SampleResultsHandler
    ) throws -> QueryHandle {
        return QueryHandle(HKSampleQuery(
            queryDescriptors: try descriptors.map { try $0.asOriginal() },
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (query, data, error) in
            guard
                error == nil,
                let results = data
            else {
                resultsHandler(QueryHandle(query), [], error)
                return
            }
            resultsHandler(QueryHandle(query), results.compactMap { try? $0.parsed() }, nil)
        })
    }
    /// Sample query whose results are converted with **collect**; the shared body of the typed queries
    func typedSampleQuery<Result>( // swiftlint:disable:this function_parameter_count
        type: ObjectType,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        limit: Int,
        collect: @escaping ([HKSample]) -> [Result],
        resultsHandler: @escaping ([Result], Error?) -> Void
    ) throws -> QueryHandle {
        guard let sampleType = type.hkObjectType as? HKSampleType else {
            throw HealthKitError.invalidType("\(type) can not be represented as HKSampleType")
        }
        return QueryHandle(HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { (_, data, error) in
            guard
                error == nil,
                let results = data
            else {
                resultsHandler([], error)
                return
            }
            resultsHandler(collect(results), nil)
        })
    }
}
