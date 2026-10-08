# 4. Contract changes for the next major release

Date: 08.10.2026

## Status

Accepted. Ships as one major release of HealthKitReporter together with a release of the `health_kit_reporter` Flutter plugin.

## Context

The `health_kit_reporter` Flutter plugin consumes the payloads as JSON from `encoded()` and sends dictionaries back to `make(from:)`. Renaming a key or changing the meaning of a value breaks it. The audit found several outputs that were wrong but already part of that contract:

- metadata with mixed value types was dropped, and the JSON nested values as `{"string": {"dictionary": ...}}` (C3);
- vision prescription dates were milliseconds while every other payload date is seconds (W4);
- negative infinity was encoded as `"inf"` and NaN as `"-500.0"` (S2);
- several description strings were misspelled (S5).

Fixing each one changes what consumers read.

## Decision

Fix all of them in one major release instead of spreading breaking changes over several:

| Change | Before | After |
| :--- | :--- | :--- |
| Metadata shape (ADR 0002) | `{"string": {"dictionary": {...}}}`, one value type per dictionary | flat object; strings, numbers, booleans, `{"timestamp"}` dates, `{"value", "unit"}` quantities |
| Vision prescription dates | milliseconds since 1970 | seconds since 1970 |
| Non-finite numbers | `"inf"` for both infinities, `"-500.0"` for NaN | `"Infinity"`, `"-Infinity"`, `"NaN"` |
| Descriptions | "Pickerball", "Handy Cycling", "Prepare and Recovery", "Sinus rhytm", "Pause on resume request" | "Pickleball", "Hand Cycling", "Preparation and Recovery", "Sinus rhythm", "Pause or resume request" |

HealthKit types also leave the public API in the same release (ADR 0005):

| Change | Before | After |
| :--- | :--- | :--- |
| Query typealiases | `Query`, `SampleQuery`, `ObserverQuery`, `StatisticsQuery`, `StatisticsCollectionQuery`, `AnchoredObjectQuery`, `SourceQuery`, `CorrelationQuery`, `ActivitySummaryQuery`, `DocumentQuery`, `VerifiableClinicalRecordQuery`, `QuantitySeriesSampleQuery`, `WorkoutEffortRelationshipQuery`, `UserAnnotatedMedicationQuery` | `QueryHandle`, returned by every reader and observer method |
| `executeQuery` / `stopQuery` | take `HKQuery` | take `QueryHandle` |
| Handler `query` parameter | `Query?` | `QueryHandle?` (`SampleResultsHandler`, `AnchoredResultsHandler`, `ObserverUpdateHandler`, `ObserverCompletionUpdateHandler`, `ObserverDescriptorsUpdateHandler`) |
| `Anchor` | `HKQueryAnchor`; default `HKQueryAnchor(fromValue: HKAnchoredObjectQueryNoAnchor)` | `Codable` struct, encodes as a base64 string; default `nil` |
| `ObjectType.original` | public `HKObjectType?` on every type enum | removed; `ObjectType` requires `identifier` |
| `SampleType.identifier` | declared on `SampleType` | declared on `ObjectType`, so characteristic, activity summary and medication types have it too |
| Payload factories | public `collect(results:)` (`[HKSample]`), `Quantity.collect(results:unit:)`, `VerifiableClinicalRecord.collect(results:)`, `DeletedObject.collect(deletedObjects:)` | internal; use the reader queries |
| `PreferredUnit.collect(from: [HKQuantityType: HKUnit])` | public | internal; `collect(from: [QuantityType: String])` stays |
| `Dictionary.sampleTypePredicates` | public | internal |
| `NSPredicate.samplesPredicate(options:)` | `HKQueryOptions` | `SamplePredicateOptions` (`.strictStartDate`, `.strictEndDate`) |
| `CustomStringConvertible` on HealthKit enums | `description` / `detail` on `HKCategoryValue…`, `HKBiologicalSex`, `HKBloodType`, `HKFitzpatrickSkinType`, `HKActivityMoveMode`, `HKWorkoutActivityType`, `HKWorkoutEventType`, `HKVisionPrescriptionType`, `HKElectrocardiogram.Classification` / `SymptomsStatus` | removed; payload strings are unchanged |

Payloads keep the identity of the stored HealthKit sample:

| Change | Before | After |
| :--- | :--- | :--- |
| `writer.save(sample:completion:)` | `StatusCompletionBlock` `(success, error)` | `SaveCompletionBlock` `(success, uuid, error)`; `uuid` of the stored sample, `nil` on failure |
| `writer.delete(sample:)` | rebuilt the sample and deleted that unsaved copy, which never matched | deletes the stored sample with the payload's `uuid`; an unknown `uuid` completes with an error |
| `addQuantity` / `addCategory` | passed a rebuilt, unsaved workout | add to the stored workout with the payload's `uuid` |
| `unrelateWorkoutEffort` | rebuilt the effort sample | unrelates the stored effort sample with the payload's `uuid`; `relateWorkoutEffort` uses the stored sample when there is one |
| `Sample` protocol | `startTimestamp`, `endTimestamp` | also requires `uuid` and `identifier` |
| `Statistics`, `WorkoutEvent` | conform to `Sample` | `Codable` only; neither is a stored sample |
| Payload `init` / `copyWith` | `init` and `copyWith` always created a new `uuid` | `init(uuid:…)` defaults to a new `uuid`; `copyWith` keeps it, `copyWith(uuid:)` sets it |
| `make(from:)` | ignored `"uuid"` | reads `"uuid"`, a new one when missing |
| `Quantity.converted(to:)` | new `uuid` and the app's own `sourceRevision` | keeps every field but the value and unit |
| `reader.workoutEffortRelationshipQuery` | non-throwing | `throws`; anchor data that doesn't hold a HealthKit anchor throws `invalidValue` (also in `anchoredObjectQuery`, which used to restart from the beginning) |
| `correlationQuery(typePredicates:)` | unknown identifiers were ignored | throw `invalidType` |
| `save(sample: Workout)` | dropped flights climbed when swimming strokes were set | completes with `invalidValue`; `saveWorkout` keeps both |

In the Flutter plugin this means: keep `QueryHandle` instead of `ObserverQuery` / `SampleQuery` for running and stopping queries, persist `Anchor` as its encoded string, pass `SamplePredicateOptions` to `samplesPredicate`, send the `uuid` back in dictionaries for delete and unrelate, and read the `uuid` the save completion reports.

Each change is committed as `feat!` / `fix!` with a `BREAKING CHANGE:` footer, so release-please bumps the major version.

The decoding of symptom samples with the severity enum (W7) also changes `description` / `detail` strings. It is shipped as a fix, because the previous strings were wrong for every value but "not present".

New fields added in the same release (statistics duration and per-source values, activity summary move time, workout statistics and activities, vision prescription lenses) are optional, so older JSON keeps decoding.

## Consequences

- One coordinated upgrade for Flutter consumers, with a single migration list.
- The Flutter plugin must, in its matching release: read and send the flat metadata object; stop dividing vision prescription dates by 1000; parse `"Infinity"`, `"-Infinity"` and `"NaN"` in numeric fields; and update any comparisons against the old description strings.
- The library release must not be published before the plugin release is ready, or plugin users get the new JSON with the old parser.
