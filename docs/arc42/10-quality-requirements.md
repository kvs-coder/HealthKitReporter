# 10. Quality Requirements

## 10.1 Quality Tree

```text
Quality
├── Compatibility
│   ├── Contract stability ........ S1, S2
│   └── Platform safety ........... S3, S4
├── Reliability
│   ├── Data fidelity ............. S5, S6
│   └── Concurrency correctness ... S7
├── Maintainability
│   ├── Extensibility ............. S8
│   └── Testability ............... S9
└── Usability
    └── Learnability .............. S10
```

## 10.2 Quality Scenarios

| ID | Scenario | Expected response |
| :--- | :--- | :--- |
| S1 | A Flutter plugin release built against version N decodes JSON from library version N.x. | Decodes without error; new fields are optional. |
| S2 | A contributor renames a `Codable` property. | Payload round-trip tests fail; if intended, the commit is `!` / `BREAKING CHANGE:` and release-please bumps the major. |
| S3 | An app on iOS 15 asks for a type introduced in iOS 18. | `original` is `nil`; the call throws `HealthKitError.notAvailable` / `invalidType` instead of crashing. |
| S4 | The package is built for watchOS. | Builds without iOS-only HealthKit symbols (CI `package` job). |
| S5 | A sample with mixed metadata (string, boolean, quantity, date) is read and written back. | All values survive; an unsupported write value throws `invalidValue`. |
| S6 | A quantity is read in a unit incompatible with its type. | `compatibleUnit(from:)` throws `invalidValue` at query build time. |
| S7 | 50 ECG samples are read with voltage measurements. | Handler is called once, results in sample order, first error reported, no data race. |
| S8 | Apple adds a new quantity type. | One enum case, one `original` mapping and one SI unit — the compiler flags every exhaustive switch to update. |
| S9 | A PR adds a payload. | Round-trip and dictionary tests exist; coverage stays ≥ `COVERAGE_THRESHOLD`. |
| S10 | A new Swift developer wants step counts for last week. | Finds a README snippet and the Example demo; needs only `HealthKitReporter`, `reader.quantityQuery`, `manager.executeQuery`. |
