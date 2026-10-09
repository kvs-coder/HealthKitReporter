# 3. Context and Scope

## 3.1 Business Context

```mermaid
flowchart LR
    user(["End user<br/>Owns the health data and grants authorization"])
    app["Consumer app<br/>Swift iOS / watchOS app"]
    flutter["health_kit_reporter<br/>Flutter plugin; talks JSON over a method channel"]
    hkr["HealthKitReporter<br/>Swift package: typed, Codable wrapper over HealthKit"]
    health[("Apple Health / HealthKit<br/>HKHealthStore, authorization UI, background delivery")]

    user -->|Uses| app
    app -->|"Reads, writes, observes<br/>Swift API, payload structs"| hkr
    flutter -->|"Reads, writes, observes<br/>encoded() JSON / make(from:) dictionaries"| hkr
    hkr -->|"Queries, saves, observes<br/>HealthKit framework"| health
    user -->|"Grants / denies access<br/>System authorization sheet"| health
```

| Partner | Input to HealthKitReporter | Output from HealthKitReporter |
| :--- | :--- | :--- |
| Consumer app (Swift) | Library types (`QuantityType`, `Quantity`, ...), predicates, callbacks | Payload structs, `HealthKitError`, `QueryHandle`s to run and stop, `Anchor`s |
| Flutter plugin | Type identifiers as strings, payload dictionaries (`[String: Any]`) | Payload JSON strings (`encoded()`) |
| HealthKit | `HK*` samples, statistics, query results, authorization status | `HK*` queries, samples to save/delete, authorization requests |
| End user | Authorization decisions (via the system sheet) | — |

## 3.2 Technical Context

| Channel | Technology | Notes |
| :--- | :--- | :--- |
| Library ⇄ consumer | Swift function calls returning `QueryHandle`s, completion closures (typealiases in `HealthKitReporter.swift`); only library and Foundation types cross this boundary (ADR 0005) | Callbacks arrive on HealthKit's background queues; consumers hop to the main queue themselves. |
| Library ⇄ Flutter plugin | JSON strings and `[String: Any]` dictionaries | Non-finite numbers are encoded as `"Infinity"`, `"-Infinity"`, `"NaN"`. |
| Library ⇄ HealthKit | `HKHealthStore`, `HKQuery` subclasses, `HKAttachmentStore`, builders | One `HKHealthStore` per `HealthKitReporter` instance. |

## 3.3 Scope

**In scope:** mapping of HealthKit object, sample and characteristic types; reading, writing, observing and deleting
data already in Health; authorization; statistics; series; attachments; workout reports and builder-based saving.

**Out of scope (ADR 0003):** live workout sessions (`HKWorkoutSession`, `HKLiveWorkoutBuilder`, mirroring),
async/await API variants, any persistence, sync or network layer.
