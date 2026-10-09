//
//  HealthKitReader+ActivitySummary.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

// MARK: - ActivitySummary
extension HealthKitReader {
    /**
     Queries activity summary.
     - Parameter predicate: **NSPredicate** predicate (optional). nil by default
     - Parameter monitorUpdates: **Bool** set true to monitor updates. False by default.
     - Parameter completionHandler: returns a block with activity summary array
     */
    public func queryActivitySummary(
        predicate: NSPredicate? = nil,
        monitorUpdates: Bool = false,
        completionHandler: @escaping ActivitySummaryCompletionHandler
    ) -> QueryHandle {
        let resultsHandler: ActivitySummaryUpdateHandler = { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler([], error)
                return
            }
            do {
                completionHandler(
                    try result.converted(name: \.parsingName) { try ActivitySummary(activitySummary: $0) },
                    nil
                )
            } catch {
                completionHandler([], error)
            }
        }
        let query = HKActivitySummaryQuery(predicate: predicate, resultsHandler: resultsHandler)
        if monitorUpdates {
            query.updateHandler = resultsHandler
        }
        return QueryHandle(query)
    }
}
