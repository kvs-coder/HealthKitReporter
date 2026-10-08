# 1. Single source for SI units and identifier lookup

Date: 08.10.2026

## Status

Accepted

## Context

Payloads harmonize every HealthKit quantity to one SI unit. The unit per `QuantityType` was a ~170-line `switch` copied into both `HKQuantitySample.harmonize()` and `HKStatistics.harmonize()`, so every new quantity type needed two identical edits.

Looking up a wrapped type by its HealthKit identifier was also done three times:

- `String.objectType` tried each type family in turn;
- `Dictionary.sampleTypePredicates` repeated that list, but checked `CharacteristicType` (never an `HKSampleType`) and left out `ClinicalType`;
- `HKQuantityType.parsed()` and `HKCategoryType.parsed()` scanned every case linearly, once per sample.

Both copies left out `VisionPrescriptionType`, and the copies had already drifted apart.

## Decision

- `HKQuantityType.siUnit` is the only place that maps a quantity type to its SI unit. Sample and statistics harmonization both read it.
- A single identifier → `ObjectType` dictionary, built once from the `allCases` of every type family, backs `String.objectType`. `sampleTypePredicates`, `HKQuantityType.parsed()` and `HKCategoryType.parsed()` go through `String.objectType`.
- A new type family is registered by adding its `allCases` to that dictionary.

## Consequences

- Adding a `QuantityType` case needs one SI unit edit, enforced by the exhaustive switch.
- Identifier lookup is a dictionary hit instead of a linear scan per sample.
- `String.objectType` and `sampleTypePredicates` now also resolve vision prescription types, and `sampleTypePredicates` resolves clinical types. No payload or dictionary contract changes.
