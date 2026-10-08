# 5. Query handles and codable anchors

Date: 08.10.2026

## Status

Accepted. Breaking change, released in 4.0.0 together with ADR 0004.

## Context

Public API takes and returns library types, yet the reader returned HealthKit queries through typealiases (`Query = HKQuery`, `SampleQuery = HKSampleQuery`, `ObserverQuery`, `StatisticsQuery`, `StatisticsCollectionQuery`, `AnchoredObjectQuery`, `SourceQuery`, `CorrelationQuery`, `ActivitySummaryQuery`, `DocumentQuery`, `VerifiableClinicalRecordQuery`, `QuantitySeriesSampleQuery`, `WorkoutEffortRelationshipQuery`, `UserAnnotatedMedicationQuery`), and anchored queries took and returned `Anchor = HKQueryAnchor`.

- Consumers got the whole `HKQuery` class and could bypass the library, for example by replacing its handlers.
- Every new query kind added another typealias.
- `HKQueryAnchor` can only be persisted through `NSKeyedArchiver`, which is awkward for the Flutter plugin, the main consumer that keeps anchors between sessions.

## Decision

- **`QueryHandle`**: a `final class` wrapping the internal `HKQuery`. Every reader and observer method returns it, `HealthKitManager.executeQuery(_:)` and `stopQuery(_:)` take it, and callbacks that used to pass `Query?` pass `QueryHandle?`. It exposes nothing but identity (`==` compares the wrapped query).
- **`Anchor`**: a `Codable` struct holding the securely archived `HKQueryAnchor` bytes. It encodes as one base64 string, so it can be stored as plain data or text. Anchored and workout effort callbacks return it, and `anchoredObjectQuery(anchor:)` / `workoutEffortRelationshipQuery(anchor:)` accept it (`nil` starts from the beginning).
- All HealthKit query typealiases are removed. A swiftlint custom rule (`no_public_healthkit_types`) fails any public declaration in `Sources/` that names an `HK*` type.

## Consequences

- One query type to learn; no HealthKit import needed to use the library.
- Consumers can no longer read or configure the underlying query (predicate, limit, handlers). Everything they need is a parameter of the reader method.
- Anchors survive app restarts and the method channel as a string.
- Tests that inspected query properties or drove HealthKit handlers directly are gone, since tests use the public API only; coverage of the library drops accordingly and the CI gate follows the new measured level.
