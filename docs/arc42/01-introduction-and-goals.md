# 1. Introduction and Goals

## 1.1 Requirements Overview

HealthKitReporter is a Swift package that wraps Apple's **HealthKit** framework. It turns `HK*` objects into plain,
`Codable` payload structs and back, so consumers can read, write and observe Apple Health data without handling
HealthKit types directly.

Core capabilities:

| Capability | Entry point | Examples |
| :--- | :--- | :--- |
| Read | `HealthKitReporter.reader` | sample, anchored, statistics (collection), series, correlation, activity summary, clinical records, documents, medications, wellbeing, workouts |
| Write | `HealthKitReporter.writer` | add / save / delete samples, builder-based workout saving, quantity and heartbeat series, workout effort relations |
| Observe | `HealthKitReporter.observer` | observer queries (single type or query descriptors), background delivery |
| Manage | `HealthKitReporter.manager` | authorization and its request status, query execution and stop, preferred units, attachments, earliest permitted sample date |
| Serialize | every payload | `encoded()` → JSON, `make(from:)` ← `[String: Any]` |

The main downstream consumer is the [`health_kit_reporter`](https://pub.dev/packages/health_kit_reporter) Flutter
plugin, which passes payloads as JSON over a method channel.

## 1.2 Quality Goals

| Priority | Quality goal | Motivation |
| :--- | :--- | :--- |
| 1 | **Contract stability** | JSON keys and `make(from:)` dictionary keys are a public contract with the Flutter plugin. A rename breaks users silently at runtime, not at compile time. |
| 2 | **Data fidelity** | Values, units, dates and metadata survive HK → payload → JSON → payload → HK without loss; a failure surfaces as `HealthKitError`, never as dropped data. |
| 3 | **Platform safety** | Runs on iOS 15+ / watchOS 8+ while exposing APIs up to the newest SDK; nothing newer than the deployment target is reachable without an availability guard. |
| 4 | **Testability** | Payload and type mapping is verifiable without a HealthKit entitlement; CI enforces a coverage floor. |
| 5 | **Learnability** | Library-typed API with documented callbacks and one way to do each thing; the Example app demonstrates every feature. |

## 1.3 Stakeholders

| Role | Expectation |
| :--- | :--- |
| Swift app developers | A typed, documented API over HealthKit with predictable errors. |
| `health_kit_reporter` Flutter plugin maintainers | A stable JSON / dictionary contract; breaking changes only in coordinated major releases (ADR 0004). |
| Library maintainers / contributors | Clear layering and conventions so new HealthKit types are added mechanically. |
| End users of consuming apps | Their health data is read and written correctly, and only with their authorization. |
