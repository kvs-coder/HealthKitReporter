# 9. Architecture Decisions

Architecture decisions are recorded as Nygard-style ADRs (status / context / decision / consequences) in
[`docs/adr/`](../adr/). That directory is the single source; this chapter only indexes it. A new decision gets the next
sequential number there and a row here.

| ADR | Title | Status | Summary |
| :--- | :--- | :--- | :--- |
| [0001](../adr/0001-single-source-si-units-and-type-registry.md) | Single source for SI units and identifier lookup | Accepted | `HKQuantityType.siUnit` is the only SI unit map; one identifier → `ObjectType` dictionary backs every lookup. |
| [0002](../adr/0002-metadata-holds-mixed-values.md) | Metadata holds mixed values | Accepted (breaking, next major) | `Metadata` is a struct of typed `Value`s encoded as one flat JSON object; invalid values throw instead of being dropped. |
| [0003](../adr/0003-workout-and-query-scope.md) | Scope of workout and query wrappers | Accepted | Wrap the iOS 16+ workout model, builder-based saving, workout effort and descriptor/series/attachment APIs; leave live sessions and async/await out. |
| [0004](../adr/0004-contract-changes-for-the-next-major-release.md) | Contract changes for the next major release | Accepted | Batch metadata shape, vision prescription seconds, non-finite encoding and description fixes into one major release coordinated with the Flutter plugin. |

Decisions embodied in the code but not (yet) recorded as ADRs — candidates if they are ever revisited:

- Facade with one injected `HKHealthStore` and no singletons (chapter 4, decision 1).
- Reader/observer methods return queries instead of executing them (chapter 4, decision 2).
- SwiftPM as the only distribution channel after the CocoaPods freeze (chapter 2).
