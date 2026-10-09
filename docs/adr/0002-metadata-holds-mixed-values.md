# 2. Metadata holds mixed values

Date: 08.10.2026

## Status

Accepted. Breaking change, released in the next major version together with the `health_kit_reporter` Flutter plugin.

## Context

`Metadata` was an enum with three cases, each wrapping a whole dictionary: `[String: String]`, `[String: Date]` or `[String: Double]`. `Metadata.make(from:)` accepted a dictionary only if it cast as a whole to one of them.

Real HealthKit metadata mixes types: `HKMetadataKeyTimeZone` is a `String`, `HKMetadataKeyWasUserEntered` an `NSNumber` boolean, `HKMetadataKeyHeartRateEventThreshold` an `HKQuantity`, and apps add dates. Such a dictionary failed every cast, and `asMetadata` turned the failure into `nil` with `try?`. Metadata was lost without an error on every read (`harmonize()`) and every write (`Harmonized.make(from:)` → `asOriginal()`).

The synthesized `Codable` encoding also nested the values as `{"string": {"dictionary": {...}}}`, and encoded `.date` values as seconds since 2001, while every other payload date is seconds since 1970.

## Decision

`Metadata` becomes a struct holding `[String: Metadata.Value]`. `Value` is one of:

| Case | HealthKit value | JSON |
| :--- | :--- | :--- |
| `.string` | `String` | `"Europe/Berlin"` |
| `.number` | `NSNumber` | `4.5` |
| `.bool` | boolean `NSNumber` | `true` |
| `.date(timestamp:)` | `Date` | `{"timestamp": 1626884800}` (seconds since 1970) |
| `.quantity(value:unit:)` | `HKQuantity` | `{"value": 120, "unit": "count/min"}` |

- `Metadata` encodes as one flat JSON object, so the Flutter side reads it as a plain `Map<String, dynamic>`.
- `Metadata.make(from:)` accepts the same shapes from a dictionary and throws `HealthKitError.invalidValue` on any other value. Payload `make(from:)` methods propagate that error instead of dropping metadata.
- On the read path, a value no table entry can express is skipped on its own, not the whole dictionary and not the sample: one unreadable metadata field must not hide the sample it describes. Since 4.1.1 this is the only conversion that skips instead of reporting `HealthKitError.parsingFailed`.
- `HKQuantity` doesn't expose its unit, so a read quantity is expressed in the first compatible unit of a fixed list (count/min, m/s, m, kcal/hr·kg, degC, %, s, kcal, kg, L, mmHg, dBASPL, mL/kg·min, mg/dL, mmol/L, IU, S, V, L/min, dBHL; deg, D, pD on iOS 16+; lux, W on iOS 17+; count). 4.1.1 added the concentration, clinical and vision units, so in practice only an amount without a volume (e.g. mmol) is still skipped.
- Writing converts back to `String`, `NSNumber`, `Date` and `HKQuantity`; a malformed quantity unit throws `HealthKitError.invalidValue`.
- Dictionary literals keep working: `["HKWasUserEntered": true, "HKTimeZone": "Europe/Berlin"]`.

## Consequences

- Mixed metadata survives reading and writing; invalid input fails loudly.
- **Breaking:** the `Metadata` enum cases and `Metadata.original` are gone, and the JSON shape changes from the nested `{"string": {"dictionary": ...}}` to a flat object. The Flutter plugin must send and read the flat shape in the same major release.
