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
    @available(iOS 9.3, *)
    public func queryActivitySummary(
        predicate: NSPredicate? = nil,
        monitorUpdates: Bool = false,
        completionHandler: @escaping ActivitySummaryCompletionHandler
    ) -> ActivitySummaryQuery {
        let resultsHandler: ActivitySummaryUpdateHandler = { (_, data, error) in
            guard
                error == nil,
                let result = data
            else {
                completionHandler([], error)
                return
            }
            var summaries = [ActivitySummary]()
            for element in result {
                do {
                    let summary = try ActivitySummary(activitySummary: element)
                    summaries.append(summary)
                } catch {
                    continue
                }
            }
            completionHandler(summaries, nil)
        }
        let query = HKActivitySummaryQuery(predicate: predicate, resultsHandler: resultsHandler)
        if monitorUpdates {
            query.updateHandler = resultsHandler
        }
        return query
    }
}
