//
//  QueryHandle.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

/// A query built by the reader or observer. Run it with **HealthKitManager.executeQuery**,
/// stop it with **HealthKitManager.stopQuery**
public final class QueryHandle {
    let query: HKQuery

    init(_ query: HKQuery) {
        self.query = query
    }
}
// MARK: - Equatable
extension QueryHandle: Equatable {
    /// Two handles are equal when they wrap the same query
    public static func == (lhs: QueryHandle, rhs: QueryHandle) -> Bool {
        return lhs.query === rhs.query
    }
}
