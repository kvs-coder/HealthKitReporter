# 2. Architecture Constraints

## 2.1 Technical Constraints

| Constraint | Background |
| :--- | :--- |
| iOS 15.0 / watchOS 8.0 deployment target | `Package.swift` `platforms`. Every newer API needs `@available` / `#available` with a `HealthKitError.notAvailable` fallback or a graceful degradation. |
| Swift only, single target | One SwiftPM library target `HealthKitReporter` (`path: Sources`), no ObjC/C targets, no third-party dependencies. |
| HealthKit as the only data source | All data lives in `HKHealthStore`; the library keeps no storage, cache or network connection of its own. |
| HealthKit needs an entitlement and user authorization | Queries cannot run in the unit-test host. Tests cover mapping only; store interaction is verified through the Example app. |
| iOS-only HealthKit APIs | Clinical records, verifiable clinical records and CDA documents are wrapped in `#if os(iOS)` so the watchOS build stays clean. |
| Callback-based API | HealthKit's completion-handler style is mirrored; async/await variants are out of scope (ADR 0003). |

## 2.2 Organizational Constraints

| Constraint | Background |
| :--- | :--- |
| Distribution via Swift Package Manager | CocoaPods is frozen at `3.1.0` (trunk read-only since 02.12.2026); no CocoaPods files are re-added. |
| Releases via release-please | Conventional Commits on `master` determine the SemVer bump and `CHANGELOG.md`; tags are bare `X.Y.Z`. No manual tagging or version edits. |
| CI gates on every PR | SwiftLint (against `.swiftlint.baseline`), iOS tests with a coverage floor, watchOS build, Example app build, changelog/manifest guard. |
| Test-first | Every payload and type has XCTest coverage before production code changes. |

## 2.3 Conventions

| Convention | Background |
| :--- | :--- |
| Dictionary / JSON contract | `make(from:)` keys and `Codable` property names are consumed by the Flutter plugin; changing one is a major release. |
| Dates as `Double` seconds since 1970 | Uniform across all payloads (vision prescriptions aligned in ADR 0004). |
| Units as strings | Produced by `HKUnit.unitString`, parsed with `HKUnit(from:)`; SI defaults live in one place (ADR 0001). |
| One error type | `HealthKitError` with a descriptive message; no `NSError`, no `fatalError`, no `try!` in new code. |
| No singletons, no static-only utility types | Consumers instantiate `HealthKitReporter()`; helpers are extensions on the type they belong to. |
| Swift API Design Guidelines, SwiftLint, line length ≤ 110 | `.swiftlint.yml`, `CONTRIBUTING.md`. |
