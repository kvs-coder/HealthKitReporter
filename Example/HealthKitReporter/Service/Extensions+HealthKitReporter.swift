//
//  Extensions+HealthKitReporter.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import Foundation
import HealthKitReporter

/// Every type the library supports, split into what HealthKit lets an app read and write
extension HealthKitReporter {
    /// Every sample type available on this OS. Correlations are left out:
    /// HealthKit authorizes their component types instead
    var demoSampleTypes: [SampleType] {
        let types: [[SampleType]] = [
            QuantityType.allCases,
            CategoryType.allCases,
            SeriesType.allCases,
            WorkoutType.allCases,
            DocumentType.allCases,
            ElectrocardiogramType.allCases,
            AudiogramType.allCases,
            StateOfMindType.allCases,
            ScoredAssessmentType.allCases
        ]
        return types.joined().filter { $0.identifier != nil }
    }

    /// Read access: every sample type, characteristics and activity summaries.
    /// Clinical records start Health's records flow, which needs an Apple Account,
    /// so they have their own request;
    /// vision prescriptions and medications use per-object authorization
    var demoReadTypes: [ObjectType] {
        var types: [ObjectType] = demoSampleTypes
        types += CharacteristicType.allCases.filter { $0.identifier != nil } as [ObjectType]
        types += ActivitySummaryType.allCases.filter { $0.identifier != nil } as [ObjectType]
        return types
    }

    /// Clinical record types, requested separately from everything else
    var demoClinicalTypes: [ObjectType] {
        return ClinicalType.allCases.filter { $0.identifier != nil }
    }

    /// Write access: every sample type HealthKit lets apps write
    var demoWriteTypes: [SampleType] {
        return demoSampleTypes.filter(\.isWritable)
    }

    var demoQuantityTypes: [QuantityType] {
        return QuantityType.allCases.filter { $0.identifier != nil }
    }
    var demoCategoryTypes: [CategoryType] {
        return CategoryType.allCases.filter { $0.identifier != nil }
    }
}
// MARK: - Counting
extension HealthKitReporter {
    /// Runs one query per type and reports how many samples each type has, plus the first one as JSON
    func countEveryType<Type, Item>(
        _ types: [Type],
        completion: @escaping DemoCompletion,
        makeQuery: (Type, @escaping ([Item]) -> Void) throws -> QueryHandle
    ) {
        let group = DispatchGroup()
        let lock = NSLock()
        var counts = [String: Int]()
        var first: Item?
        for type in types {
            group.enter()
            do {
                let query = try makeQuery(type) { items in
                    lock.lock()
                    counts[(type as? SampleType)?.identifier ?? "\(type)"] = items.count
                    first = first ?? items.first
                    lock.unlock()
                    group.leave()
                }
                manager.executeQuery(query)
            } catch {
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            let withData = counts.filter { $0.value > 0 }.sorted { $0.value > $1.value }
            var lines = ["\(withData.count) of \(types.count) types have samples this week"]
            lines += withData.prefix(8).map { "\($0.key.shortIdentifier): \($0.value)" }
            if let first = first as? Encodable {
                lines.append("first:\n\(first.json)")
            }
            completion(.success(lines.joined(separator: "\n")))
        }
    }
}
// MARK: - Publisher
extension HealthKitReporter {
    /// One result: wraps a callback based library call in a publisher
    func publisher(
        _ body: @escaping (@escaping DemoCompletion) throws -> Void
    ) -> AnyPublisher<String, Error> {
        return Deferred {
            Future { promise in
                do {
                    try body(promise)
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
