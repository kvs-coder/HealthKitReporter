# 8. Crosscutting Concepts

## 8.1 Harmonization (HK ⇄ payload)

Two internal protocols carry every conversion:

| Protocol | Direction | Shape |
| :--- | :--- | :--- |
| `Harmonizable` | HK → payload value | `associatedtype Harmonized: Codable; func harmonize() throws -> Harmonized` — implemented by `HK*` extensions in `Sources/Decorator/` |
| `Original` | payload → HK | `associatedtype Object: NSObject; func asOriginal() throws -> Object` — implemented by payloads |
| `Payload` (public) | dictionary → payload | `static func make(from: [String: Any]) throws -> Self` |

The internal `Factory.collect(results:)` turns a HealthKit result array into payloads and *skips* samples that fail to convert,
so one malformed sample does not fail a whole query.

## 8.2 Units

- Each `QuantityType` has exactly one SI unit, defined only in `HKQuantityType.siUnit` (ADR 0001); sample and
  statistics harmonization both read it. The exhaustive switch forces a unit for every new case.
- Consumers may request another unit as a string; it is parsed with `HKUnit(from:)` and checked for compatibility
  (`compatibleUnit(from:)`), throwing `HealthKitError.invalidValue` otherwise.
- Units travel as `HKUnit.unitString`; payloads never hardcode unit literals.

## 8.3 Identifiers and type lookup

HealthKit identifier strings resolve to library types through one dictionary built from every family's `allCases`
(`String.objectType`). `ObjectType.make(from:)` resolves within one family and throws
`HealthKitError.invalidIdentifier`.

## 8.4 Serialization contract

- JSON comes from `Encodable.encoded()`: pretty-printed, non-finite numbers as `"Infinity"`, `"-Infinity"`, `"NaN"`.
- Dates are `Double` seconds since 1970 everywhere.
- Dictionary input reads numbers as `NSNumber` and converts with `Double(truncating:)`; missing required keys throw
  `HealthKitError.invalidValue("Invalid dictionary: ...")`.
- `Metadata` is a flat object of strings, numbers, booleans, `{"timestamp"}` dates and `{"value","unit"}` quantities
  (ADR 0002).
- New fields are optional so older JSON keeps decoding; renames and meaning changes are major releases (ADR 0004).

## 8.5 Error handling

`HealthKitError` is the only error the library throws: `notAvailable`, `unknown`, `invalidType`, `invalidIdentifier`,
`invalidOption`, `invalidValue`, `parsingFailed`, `badEncoding`, `notImplementable`, each with a descriptive message.

- Invalid input throws synchronously when a query or `HK*` object is built.
- HealthKit errors are passed through unchanged as the `error` element of the callback.
- Result handlers follow `guard error == nil, let results = data else { handler([], error); return }`.
- Unknown cases of Apple's non-frozen enums are described (e.g. as "Unknown"), not crashed on.

## 8.6 Platform availability

- Type enums return `nil` from the internal `original` (and so from `identifier`) for cases the running OS lacks;
  services treat `nil` as `invalidType` or `notAvailable`.
- Newer APIs carry `@available(iOS X, watchOS Y, *)` or `if #available` with a `HealthKitError.notAvailable` fallback.
- iOS-only HealthKit APIs (health records, CDA documents) are compiled only under `#if os(iOS)`.

## 8.7 Concurrency

- HealthKit calls back on its own background queues; the library does no queue hopping, and documents that consumers
  dispatch to the main queue for UI.
- Payloads are immutable value types (`public let`, `copyWith`), safe to pass across threads.
- Fan-out retrieval joins through `SampleResultsCollector` (private serial queue + `DispatchGroup`), which removes the
  data race of appending from concurrent callbacks and keeps a deterministic order.
- Observer completion handlers are surfaced to the consumer so background work finishes before HealthKit is told.

## 8.8 Dependency management and lifetime

One `HKHealthStore` per `HealthKitReporter` instance, injected into every service through `internal init`. No
singletons; consumers decide whether to hold one reporter for the app's lifetime.

## 8.9 Testing

- Tests use the public API only (no `@testable`).
- `Tests/<Payload>Tests.swift` — one `XCTestCase` per payload: create → `encoded()` → decode round trip, and
  `make(from:)` with a Flutter-shaped dictionary; fixed timestamps, every field asserted.
- Type tests check `identifier` and `make(from:)` for new cases.
- Every query is built, run and stopped through `QueryHandle`; in the unentitled test host HealthKit answers each
  result closure with an error, which covers the closures' error paths.
- The CI coverage floor (`COVERAGE_THRESHOLD`) rises with every test PR. It was lowered once, in 4.0.0, when the
  public API stopped exposing HealthKit types and the tests that reached the mapping through it went away.
- Store-dependent paths (HK → payload mapping, builders, background delivery, attachments) are verified via the
  Example app.
