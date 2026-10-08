# 11. Risks and Technical Debt

| # | Risk / debt | Impact | Mitigation |
| :--- | :--- | :--- | :--- |
| R1 | **Contract coupling to the Flutter plugin.** The JSON shape is an untyped, cross-repo contract. | A library release ahead of the plugin breaks plugin users at runtime (ADR 0004). | Coordinated major releases; round-trip tests; publish the library only after the plugin release is ready. |
| R2 | **HealthKit types in the public API.** The query typealiases (`Query = HKQuery`, `Anchor = HKQueryAnchor`, ...), `NSPredicate`/`NSSortDescriptor` parameters and `HKUpdateFrequency` expose HealthKit directly. | Consumers depend on HealthKit types despite the "no HK leakage" goal; changing them is breaking. | Accepted as legacy; new API uses library types. Revisit in a future major release if it becomes a burden. |
| R3 | **Store-dependent code is not unit-tested.** Query execution, builders (`saveWorkout`), background delivery and attachments need an entitlement. | Regressions there surface only on device. | Example app demos for every feature; coverage gate on the mapping code. |
| R4 | **Silent sample skipping.** `collect(results:)` drops samples that fail to convert. | A mapping bug can hide data without an error. | Payload tests per type; consider reporting skipped counts if consumers need it. |
| R5 | **Metadata quantity units are guessed.** `HKQuantity` does not expose its unit, so a read quantity is expressed in the first compatible unit of a fixed list (ADR 0002). | Unusual units come back converted. | Documented in ADR 0002; extend the list when a consumer needs another unit. |
| R6 | **HealthKit API growth.** Apple adds types and APIs every year; enums with ~240 / ~140 cases must track them. | Missing types, or unguarded use of new APIs. | Exhaustive switches, availability guards, one SI-unit source. |
| R7 | **Legacy SwiftLint violations** are baselined in `.swiftlint.baseline`. | Old code does not meet current rules. | Only new violations fail CI; regenerate the baseline only when fixing legacy code. |
| R8 | **Coverage floor at 77.6 %.** `Model/` targets 100 %. | Untested mapping paths. | Threshold only rises; each test PR raises it to the new measured level. |
| R9 | **No async/await API.** | Swift consumers wrap callbacks themselves. | Out of scope per ADR 0003; add for the whole API in one major release if needed. |
