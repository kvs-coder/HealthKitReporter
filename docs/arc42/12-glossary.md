# 12. Glossary

| Term | Definition |
| :--- | :--- |
| **HealthKit** | Apple's framework and on-device database for health and fitness data. |
| **HKHealthStore** | HealthKit's access point for queries, saves and authorization; one per `HealthKitReporter` instance. |
| **Facade** | `HealthKitReporter`, the consumer's entry point exposing `reader`, `writer`, `observer`, `manager`. |
| **Service** | One of `HealthKitReader`, `HealthKitWriter`, `HealthKitObserver`, `HealthKitManager`; the only layer touching the store. |
| **Type** | A library enum case naming a HealthKit object type (e.g. `QuantityType.stepCount`), mapped through `original` and `identifier`. |
| **Identifier** | HealthKit's string name of a type (e.g. `HKQuantityTypeIdentifierStepCount`); the key the Flutter plugin uses. |
| **Payload** | A `Codable` value struct mirroring a HealthKit object (e.g. `Quantity` ⇄ `HKQuantitySample`); also the public protocol with `make(from:)`. |
| **Harmonized** | The nested value part of a payload (value, unit, metadata) in the harmonized unit. |
| **Harmonize** | Convert an `HK*` object into a payload's `Harmonized` value (`Harmonizable.harmonize()`). |
| **Original** | Convert a payload back to its `HK*` object (`Original.asOriginal()`). |
| **Decorator** | An internal extension in `Extensions+<Type>.swift` holding conversion or lookup logic. |
| **Retriever** | A helper running a multi-step query that fans out per sample (ECG voltages, heartbeat series, routes). |
| **SI unit** | The single default unit per quantity type, from `HKQuantityType.siUnit`. |
| **Metadata** | A sample's key/value annotations, held as typed `Metadata.Value`s and encoded flat. |
| **Dictionary contract** | The keys of `make(from:)` dictionaries and `Codable` property names consumed by the Flutter plugin. |
| **Observer query** | A long-running query notifying about changes in Health; paired with background delivery. |
| **Background delivery** | HealthKit waking the app on data changes at an `UpdateFrequency`. |
| **Anchor** | `HKQueryAnchor` marking the position after which an anchored query returns new and deleted objects. |
| **Query descriptor** | A type + predicate pair (`QueryDescriptor`) for reading or observing several types in one query. |
| **Statistics** | Aggregated quantity values (sum, average, min, max, most recent, duration), optionally per source. |
| **Source / SourceRevision** | The app or device that wrote a sample, and its version. |
| **Example app** | The UIKit demo in `Example/` that exercises every public feature on a device or simulator. |
