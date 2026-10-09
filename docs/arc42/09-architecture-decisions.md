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
| [0005](../adr/0005-query-handles-and-codable-anchors.md) | Query handles and codable anchors | Accepted (breaking, 4.0.0) | Reader and observer return an opaque `QueryHandle`; anchors are a `Codable` `Anchor`; no `HK*` type in the public API, enforced by a swiftlint rule. |
| [0006](../adr/0006-chained-queries-behind-one-query-handle.md) | Chained queries behind one query handle | Accepted (4.1.0) | A query needing a stored object first (workout routes by workout uuid) returns a handle on the lookup; its handler runs the follow-up query. |

Decisions embodied in the code but not (yet) recorded as ADRs — candidates if they are ever revisited:

- Facade with one injected `HKHealthStore` and no singletons (chapter 4, decision 1).
- Reader/observer methods return query handles instead of executing them (chapter 4, decision 2; the handle type itself is ADR 0005).
- SwiftPM as the only distribution channel after the CocoaPods freeze (chapter 2).
