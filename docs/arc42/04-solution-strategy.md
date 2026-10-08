# 4. Solution Strategy

| Quality goal | Strategy | Where |
| :--- | :--- | :--- |
| Contract stability | Payloads are `Codable` structs with `public let` fields; their property names *are* the JSON contract. Breaking changes are batched into coordinated major releases. | `Sources/Model/Payload/`, ADR 0004 |
| Data fidelity | Two-way mapping per payload: `Harmonizable.harmonize()` (HK → payload) and `Original.asOriginal()` (payload → HK). Units are harmonized to one SI unit per type; metadata keeps mixed value types. | `Sources/Decorator/`, ADR 0001, ADR 0002 |
| Platform safety | Every type case maps internally to `HKObjectType?` and returns `nil` under `#available` for older OSes (its public `identifier` is then `nil`); services throw `HealthKitError.notAvailable` or degrade. | `Sources/Model/Type/` |
| Testability | Tests use the public API only: payload round trips, unit and input validation, and every query run against the store (which answers with errors in the unentitled test host). The HK → payload mapping is reachable only with real data and is verified through the Example app (chapter 11, R2). | `Tests/`, `Example/` |
| Learnability | One facade with four role-specific services; one error type; one callback typealias per result shape. | `HealthKitReporter.swift` |

## Key Decisions

1. **Facade over role services.** `HealthKitReporter` creates one `HKHealthStore` and injects it into `HealthKitReader`,
   `HealthKitWriter`, `HealthKitObserver` and `HealthKitManager`. There are no singletons; the consumer owns the lifetime.
2. **Query builders, not query runners.** Reader and observer methods validate input, build and *return* an opaque `QueryHandle` (ADR 0005).
   The consumer executes it with `manager.executeQuery(_:)` and stops it with `manager.stopQuery(_:)`, which keeps
   long-running queries (observer, anchored, statistics collection) under the consumer's control.
3. **Enums for types, structs for values.** HealthKit's identifier strings become exhaustive `Int` enums
   (`QuantityType`, `CategoryType`, ...); HealthKit objects become value-type payloads.
4. **Decorators as internal glue.** All conversion logic lives in `Extensions+<Type>.swift`, one extended type per file,
   so payloads stay data and services stay orchestration.
5. **Multi-step retrieval in retrievers.** Queries that fan out (ECG voltages, heartbeat series, workout routes) live in
   `Service/Retriever/` and serialize concurrent callbacks through `SampleResultsCollector`.
