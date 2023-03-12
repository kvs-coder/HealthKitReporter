//
//  HealthKitReporter.swift
//  HealthKitReporter
//
//  Created by Victor on 23.09.20.
//

import HealthKit

/// ***HKQueryAnchor** typealias
public typealias Anchor = HKQueryAnchor
/// **HKQuery** typealias
public typealias Query = HKQuery
/// **HKObserverQuery** typealias
public typealias ObserverQuery = HKObserverQuery
/// **HKSampleQuery** typealias
public typealias SampleQuery = HKSampleQuery
/// **HKStatisticsQuery** typealias
public typealias StatisticsQuery = HKStatisticsQuery
/// **HKStatisticsCollectionQuery** typealias
public typealias StatisticsCollectionQuery = HKStatisticsCollectionQuery
/// **HKActivitySummaryQuery** typealias
@available(iOS 9.3, *)
public typealias ActivitySummaryQuery = HKActivitySummaryQuery
/// **HKAnchoredObjectQuery** typealias
public typealias AnchoredObjectQuery = HKAnchoredObjectQuery
/// **HKSourceQuery** typealias
public typealias SourceQuery = HKSourceQuery
/// **HKCorrelationQuery** typealias
public typealias CorrelationQuery = HKCorrelationQuery
/**
 - Parameters:
    - success: the status
    - error: error (optional)
 */
public typealias StatusCompletionBlock = (_ success: Bool, _ error: Error?) -> Void
/**
 - Parameters:
    - identifier: the object type identifier
    - error: error (optional)
 */
public typealias ObserverUpdateHandler = (
    _ query: Query?,
    _ identifier: String?,
    _ error: Error?
) -> Void
/**
 - Parameters:
    - success: the status
    - id: the deleted object id
    - error: error (optional)
*/
public typealias DeletionCompletionBlock = (
    _ success: Bool,
    _ id: Int,
    _ error: Error?
) -> Void
/**
 - Parameters:
    - samples: sample array. Empty by default
    - error: error (optional)
 */
public typealias SampleResultsHandler = (
    _ query: Query?,
    _ samples: [Sample],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - samples: sample array. Empty by default
    - deletedObjects: samples array that has been deleted
    - anchor: The anchor which was returned by a previous HKAnchoredObjectQuery result or update
    - error: error (optional)
 */
public typealias AnchoredResultsHandler = (
    _ query: Query?,
    _ samples: [Sample],
    _ deletedObjects: [DeletedObject],
    _ anchor: Anchor?,
    _ error: Error?
) -> Void
/**
 - Parameters:
    - series: heartbeat series.
    - error: error (optional)
 */
@available(iOS 13.0, *)
public typealias HeartbeatSeriesResultsDataHandler = (
    _ series: [HeartbeatSeries],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - routes: workout routes.
    - error: error (optional)
 */
@available(iOS 11.0, *)
public typealias WorkoutRouteResultsDataHandler = (
    _ routes: [WorkoutRoute],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - summaries: summary array. Empty by default
    - error: error (optional)
 */
@available(iOS 9.3, *)
public typealias ActivitySummaryCompletionHandler = (
    _ summaries: [ActivitySummary],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - sources: source array. Empty by default
    - error: error (optional)
 */
public typealias SourceCompletionHandler =  (
    _ sources: [Source],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - correlations: correlation array. Empty by default
    - error: error (optional)
 */
public typealias CorrelationCompletionHandler =  (
    _ correlations: [Correlation],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - samples: quantity sample array. Empty by default
    - error: error (optional)
 */
public typealias QuantityResultsHandler = (
    _ samples: [Quantity],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - samples: correlation sample array. Empty by default
    - error: error (optional)
 */
public typealias CorrelationResultsHandler = (
    _ samples: [Correlation],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - statistics: statistics. Nil by default
    - error: error (optional)
 */
public typealias StatisticsCompletionHandler = (
    _ statistics: Statistics?,
    _ error: Error?
) -> Void
/**
 - Parameters:
    - samples: category sample array. Empty by default
    - error: error (optional)
 */
public typealias CategoryResultsHandler = (
    _ samples: [Category],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - samples: workout sample array. Empty by default
    - error: error (optional)
 */
public typealias WorkoutResultsHandler = (
    _ samples: [Workout],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - preferredUnits: an array of **PreferredUnit**
    - error: error (optional)
*/
public typealias PreferredUnitsCompeltion = (
    _ preferredUnits: [PreferredUnit],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - ecgs: electrocardiogram sample array
    - error: error (optional)
 */
@available(iOS 14.0, *)
public typealias ElectrocardiogramResultsHandler = (
    _ ecgs: [Electrocardiogram],
    _ error: Error?
) -> Void
/**
 - Parameters:
    - samples: electrocardiogram voltage measurements sample array. Empty by default
    - error: error (optional)
 */

/// **HealthKitReporter** class for HK easy integration
public class HealthKitReporter {
    /// **HealthKitReader** is reponsible for reading operations in HK
    public let reader: HealthKitReader
    /// **HealthKitWriter** is reponsible for writing operations in HK
    public let writer: HealthKitWriter
    /// **HealthKitObserver** is reponsible for observing in HK
    public let observer: HealthKitObserver
    /// **HealthKitManager** is reponsible for authorization and other operations
    public let manager: HealthKitManager
    /**
     Checks if HealthData is available on the device (for instance iPad do not support Apple Health).
     Call this check before instantiating the **HealthKitReporter** instance
     - Returns: **Bool** value
     */
    public static var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    /**
     Inits the instance of **HealthKitReporter** class.
     Every time when called, the new instance of **HKHealthStore** is created.
     - Requires: Apple Healt App is installed on the device.
     - Returns: **HealthKitReporter** instance
     */
    public init() {
        let healthStore = HKHealthStore()
        self.reader = HealthKitReader(healthStore: healthStore)
        self.writer = HealthKitWriter(healthStore: healthStore)
        self.observer = HealthKitObserver(healthStore: healthStore)
        self.manager = HealthKitManager(healthStore: healthStore)
    }
}
