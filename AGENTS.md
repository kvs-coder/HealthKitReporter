# AGENTS.md — System & AI Agent Directives

> **Library Mission**: HealthKitReporter is a Swift wrapper around Apple's **HealthKit** framework, distributed via **Swift Package Manager** (iOS 15+, watchOS 8+). CocoaPods is frozen at `3.1.0` (trunk is read-only from 02.12.2026).
> It turns `HK*` objects into plain, `Codable` payload structs (and back), so consumers — including the `health_kit_reporter` Flutter plugin — can read, write and observe Apple Health data without touching HealthKit types directly.
> `Example/` hosts a UIKit demo app (MVVM with Combine) and a SwiftUI watch companion that exercise the public API end to end.

Strict engineering invariants, architectural rules, and operational protocols for AI agents and human contributors.

---

## 1. Persona & Core Principles

You operate as a **Staff Software Engineer**.
* **Engineering Standards**: Apply **KISS**, **DRY**, **SOLID**, and strict **Test-First TDD**.
* **Zero Speculation**: No code without tests. No superfluous wrappers or unnecessary abstractions.
* **Refactoring Rule**: Verify or write tests *first*. Refactoring requires a green test suite at every step.
* **Match the Surroundings**: New code reads like the code next to it — same file header, doc-comment shape, naming, `// MARK: -` layout and parameter wrapping (§5). When in doubt, copy the nearest sibling (`Quantity.swift`, `HealthKitReader.swift`).
* **API Design**: Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) (`CONTRIBUTING.md`).

---

## 2. Communication Protocols

All proposals, comments, and PR descriptions must adhere to:
1. **BLUF (Bottom Line Up Front)**: Lead immediately with the core output or decision.
2. **Pyramid Principle**: Core conclusion first, followed by structured, logical arguments.
3. **Plain English / Gutes Deutsch**: Concise, technical, zero corporate fluff.
4. **Socratic Method**: Guide architectural trade-offs via targeted questions rather than guessing.
5. **Strictly 1-2 sentences**: Answer in 1-2 sentences and never add explanations, code walk-throughs or lists unless the prompt explicitly asks for them.

---

## 3. High-Level Architecture & Directory Topology

```
HealthKitReporter (facade, one HKHealthStore per instance)
   ├──► HealthKitReader   ─┐
   ├──► HealthKitWriter   ─┤  Services (Sources/Service/) — the only layer that runs HK queries
   ├──► HealthKitObserver ─┤
   └──► HealthKitManager  ─┘
            │
            ▼
   Types (Sources/Model/Type/)       enums mapping to HKObjectType  (QuantityType.stepCount → HKQuantityType)
   Payloads (Sources/Model/Payload/) Codable structs mapping to HKObject (Quantity ⇄ HKQuantitySample)
            │
            ▼
   Decorators (Sources/Decorator/)   Extensions+<Type>.swift — HK → payload harmonization & helpers
```

### Directory Structure
`Sources/` and `Tests/` MUST keep this layout:

```text
Sources/
├── HealthKitReporter.swift          (facade + public typealiases for result and completion handlers)
├── HealthKitError.swift             (the single public error enum)
├── Decorator/
│   └── Extensions+<TypeName>.swift  (one extended type per file, e.g. Extensions+HKElectrocardiogramClassification)
├── Model/
│   ├── <Protocol>.swift             (Harmonizable, Original, Payload, UnitConvertable, ...)
│   ├── <ValueType>.swift            (Anchor, QueryHandle, QueryDescriptor, Metadata, PreferredUnit, ...)
│   ├── Payload/
│   │   └── <PayloadName>.swift      (Quantity, Category, Workout, ...)
│   └── Type/
│       ├── <TypeName>.swift         (ObjectType, CharacteristicType, HealthKitObjectTypeConvertible, ...)
│       └── Sample/
│           └── <SampleTypeName>.swift
└── Service/
    ├── HealthKit<Role>.swift        (Reader, Writer, Observer, Manager)
    ├── HealthKit<Role>+<Area>.swift (one area of a role, e.g. HealthKitReader+Statistics)
    └── Retriever/
        └── <Name>Retriever.swift    (multi-step queries, stored-sample lookups; SampleResultsCollector joins them)

Tests/
├── <PayloadName>Tests.swift         (one XCTestCase per payload)
├── <TypeName>Tests.swift            (type mappings, e.g. ObjectTypeTests, CategoryTypeTests)
├── HealthKit<Role>Tests.swift, Query*Tests.swift, StoreOperationsTests.swift (services through the public API)
├── XCTestCase+Fixtures.swift        (shared fixtures and assertions)
└── .swiftlint.yml                   (allows longer test bodies)

Example/
├── HealthKitReporter/               (UIKit MVVM demo app)
│   ├── Demo/                        (DemoViewModel, DemoViewController, DemoView, DemoCell, DemoRow…)
│   └── Service/                     (HealthKitReporterService and one DemoPerformer per library area)
├── HealthKitReporterWatch/          (SwiftUI watch companion for startWatchApp)
└── HealthKitReporter.xcodeproj  (consumes the repo root as a local Swift package)
```

### Layer Invariants
* **No HK leakage**: Public API takes and returns library types (`QuantityType`, `Quantity`, `QueryHandle`, `Anchor`). Raw `HK*` objects stay `internal` behind `Original` / `Harmonizable` / `HealthKitObjectTypeConvertible`; the `no_public_healthkit_types` lint rule enforces it.
* **Identity**: a payload's `uuid` names the stored HealthKit sample. HealthKit gives every saved object its own uuid, so writes that act on stored data (delete, add to workout, unrelate, attachments) look the stored object up by `uuid` through `StoredSampleRetriever`; never act on a fresh `asOriginal()` copy.
* **One store**: `HealthKitReporter.init()` builds one `HKHealthStore` and injects it into every service. Services never create their own.
* **Decorators are internal glue**: `Extensions+*.swift` hold conversions and helpers; they never run queries.

---

## 4. Strict Prohibitions & Bans

### Architecture & Code Bans
* ❌ **Ban on Singletons**: No `static let shared`, global instances or factory singletons. Consumers instantiate `HealthKitReporter()`; dependencies are passed through `init`.
  * **Not covered** — stateless static queries of the platform (`HealthKitReporter.isHealthDataAvailable`) and static factories on payloads/types (`Quantity.make(from:)`, `ObjectType.make(from:)`, `Quantity.collect(...)`).
* ❌ **Ban on Static-Only Utility Types**: No `enum`/`struct`/`class` that only namespaces `static` helper functions. Put behavior in an extension of the type it belongs to (`Extensions+Double.swift` → `Double.asDate`).
* ❌ **Ban on Exposing `HK*` Types in New Public API**: New public methods and payload fields use library types; mapping happens in `Original.asOriginal()` and `Harmonizable.harmonize()`.
* ❌ **Ban on Unguarded Availability**: Every API newer than the deployment target (iOS 15.0 / watchOS 8.0) MUST be gated with `@available(iOS X, *)` on the declaration or `if #available(iOS X, *)` at the call site, with an `else` that throws `HealthKitError.notAvailable("\(type) is not available for the current iOS")` or degrades gracefully.
* ❌ **Ban on Ad-hoc Errors**: Throw only `HealthKitError` cases with a descriptive message (`HealthKitError.invalidType("Invalid HKQuantityType: \(type)")`). No new error types, no `NSError`.
* ❌ **Ban on `fatalError` / `try!` / Force Casts**: Use `guard ... else { throw HealthKitError... }`; `@unknown default` arms throw or return a fallback.
* ❌ **Ban on Inputs HealthKit Raises For**: HealthKit raises Objective-C exceptions, which Swift can't catch, for invalid input (unknown raw values, end before start, disallowed authorization types). Validate in Swift before calling it and throw `HealthKitError`; never add Objective-C to catch them.
* ❌ **Ban on Silently Dropping Data**: Never skip an entry that fails to convert (`try?`, `compactMap { try? … }`, `catch { continue }`). Convert collections with `Sequence.converted(name:_:)` (or `[HKSample].converted(_:)`), so the first failure throws `HealthKitError.parsingFailed` naming the entry; a nested member that fails fails its parent.
  * **Not covered** — a read metadata value no `Metadata.Value` can express is skipped on its own (`Dictionary.asMetadata`, ADR 0002), so one metadata field never hides its sample; add a unit to `Metadata.Value.quantityUnits` instead of widening the skip.
* ❌ **Ban on Catch-all Switches over Library Enums**: A `switch` over `QuantityType`, `CategoryType`, etc. lists every case; no `default:`. `@unknown default` is required only for Apple's non-frozen enums.
* ❌ **Ban on Mutable Payloads**: Payload fields are `public let`. Changes go through `copyWith(...)`.
* ❌ **Ban on Breaking the Dictionary Contract**: `Payload.make(from:)` keys and `Codable` property names are consumed by the Flutter plugin. Renaming one is a breaking change (`!` / `BREAKING CHANGE:` commit → major release).
* ❌ **Ban on Hardcoded Units in Payloads**: Units are `String`s produced by `HKUnit.unitString` and parsed with `HKUnit(from:)`; SI defaults live only in `HKQuantitySample.harmonize()`.

### Git & VCS Bans
* ❌ **Ban on `git commit --no-verify`**: Bypassing pre-commit git hooks, static analysis, or test suites is forbidden.
* ❌ **Ban on Blind Staging (`git add .` / `git add -A`)**: Run `git status` first and stage only relevant source, test, and config files explicitly.
* ❌ **Ban on Direct Force Pushing**: Force pushing to `master` is forbidden. Use `--force-with-lease` on isolated feature branches only when necessary.
* ❌ **Ban on Single-Line Shortcut Commits**: Omitting the detailed description, `Changes:`, and `Tests:` sections in commit messages is strictly forbidden.
* ❌ **Ban on AI Attribution Trailers**: A commit message MUST NEVER carry `Co-Authored-By: <Model Name> <noreply@anthropic.com>`, or any other trailer crediting an AI model or tool.
* ❌ **Ban on Committing User or Build State**: Never commit `xcuserdata/`, `DerivedData`, `build/`, `.swiftpm/xcode/xcuserdata/` or a generated `HealthKitReporter.xcodeproj`. Never re-add CocoaPods files (`*.podspec`, `Podfile`, `Pods/`, `Gemfile`).

---

## 5. Code Style & Layer Specifications

### A. File Layout
* **Header**: every Swift file starts with the Xcode header block, then imports (`HealthKit` for anything touching HK, otherwise `Foundation`):

```swift
//
//  Quantity.swift
//  HealthKitReporter
//
//  Created by <Name> on dd.MM.yy.
//

import HealthKit
```

* **Indentation**: 4 spaces. Line length ≤ 110 in `Sources/`, `Tests/` and `Example/` (`.swiftlint.yml`).
* **Wrapping**: once a declaration or call doesn't fit on one line, put **every** argument on its own line and the closing `)` on its own line. Multi-condition `guard` lists each condition on its own line with `else` on its own line.
* **Conformances**: each protocol conformance lives in its own extension, preceded by `// MARK: - <ProtocolName>` (`// MARK: - Original`, `// MARK: - Payload`, `// MARK: - Factory`, `// MARK: - UnitConvertable`).
* **Access Control**: `public` only for consumer-facing API; HK-backed initializers and protocol plumbing (`Original`, `Harmonizable`) stay `internal`. Stored service dependencies are `private let`.

### B. Documentation Comments
Every `public` declaration carries a doc comment in the existing format — type names in **bold**, defaults spelled out, thrown cases listed:

```swift
/**
 Queries quantity types.
 - Parameter type: **QuantityType** types
 - Parameter predicate: **NSPredicate** predicate (optional). allSamples by default
 - Parameter resultsHandler: returns a block with samples
 - Throws: HealthKitError.invalidType
 */
```

Short one-liners use `/// **HealthKitWriter** class for HK writing operations`. Completion typealiases in `HealthKitReporter.swift` document each labeled tuple element under `- Parameters:`.

### C. Types (`Sources/Model/Type/`)
* A type is a `public enum <Name>: Int, CaseIterable, <ObjectType|SampleType>`.
* Internal `var original: HKObjectType?` maps each case with an exhaustive `switch`, returning `nil` under an `#available` guard for unsupported OS versions. The enum conforms to the internal `HealthKitObjectTypeConvertible` in its own `// MARK: - HealthKitObjectTypeConvertible` extension; other code reaches the HealthKit type through `ObjectType.hkObjectType`.
* Public `identifier` derives from `original?.identifier`; lookup by string goes through `ObjectType.make(from:)` or `String.objectType`.
* Whether apps may write a sample type is `SampleType.isWritable`; a type HealthKit only records itself goes into its read-only list in `SampleType.swift`.
* Adding a case means updating **every** exhaustive switch over it (e.g. `HKQuantitySample.harmonize()` unit mapping) and the `CHANGELOG.md`.

### D. Payloads (`Sources/Model/Payload/`)
A payload is a `public struct` that mirrors one `HK*` class. Writable payloads follow `Quantity.swift` exactly:
1. Nested `public struct Harmonized: Codable` for the value part (value, unit, metadata) with a public memberwise `init` and `copyWith`.
2. `public let` fields (`uuid`, `identifier`, `startTimestamp`, `endTimestamp`, `device`, `sourceRevision`, `harmonized`). Dates are `Double` seconds since 1970. Stored samples conform to `Sample` (`uuid`, `identifier`, timestamps).
3. `internal init(<hkName>: HK...) throws` from the HealthKit object.
4. `public init(uuid: String = UUID().uuidString, ...)` memberwise + `public func copyWith(...)` with every parameter `= nil` and `?? self.<field>` fallbacks; `copyWith` keeps the `uuid` unless one is passed.
5. Extensions, each behind a `// MARK: -`:
   * `Original` — `asOriginal() throws -> HK...`, `guard` + `HealthKitError.invalidType` on bad identifiers; validates what HealthKit raises for (`startTimestamp.checkInterval(to:)`, known raw values).
   * `Payload` — `static func make(from dictionary: [String: Any]) throws -> Self`; reads `"uuid"` with `dictionary.payloadUUID`, `Double`s as `NSNumber` with `Double(truncating:)`, `Int` / `Bool` with `dictionary.int(_:)` / `dictionary.bool(_:)`; missing required keys throw `HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")`. `collect(from:)` comes from the `Payload` protocol extension; don't reimplement it.
   * `Factory` — `static func collect(results: [HKSample]...) throws -> [Self]` built on `results.converted { (sample: HK...) in try Self(...) }`; a sample that fails to convert, or one of another class, throws `HealthKitError.parsingFailed`.

Read-only payloads (HealthKit doesn't let apps write them: `Electrocardiogram`, `ClinicalRecord`, `VerifiableClinicalRecord`, `ActivitySummary`, `Statistics`, `MedicationDoseEvent`, `UserAnnotatedMedication`, `Attachment`, `DeletedObject`, `Characteristic`) keep steps 1–3, the public `init` and the `Payload` extension, and leave out `Original`; `copyWith` is optional for them.

Doc comments are required on every public type, initializer, function and protocol; stored fields get one when their unit or meaning isn't obvious from the name (`/// seconds since 1970`).

### E. Decorators (`Sources/Decorator/`)
* One file per extended type: `Extensions+<TypeName>.swift`.
* `HK*` sample extensions conform to `Harmonizable` (`typealias Harmonized = <Payload>.Harmonized`; `func harmonize() throws -> Harmonized`).
* Helpers that are pure conversions are computed properties (`asDate`, `asMetadata`, `asOriginal`).

### F. Services (`Sources/Service/`)
* `public class HealthKit<Role>` with a single `let healthStore: HKHealthStore` injected via `internal init(healthStore:)`. It is `internal` rather than `private` when the role is split over `HealthKit<Role>+<Area>.swift` files, which share it; a role in one file keeps it `private`.
* **Query builders** (`HealthKitReader`, `HealthKitObserver`) validate input, build and **return** a `QueryHandle` — they never execute it. The consumer runs it with `manager.executeQuery(_:)` and stops it with `manager.stopQuery(_:)`. Anchored queries take and hand back an `Anchor`; several types go in one query through `QueryDescriptor`.
* Callbacks use the public typealiases declared in `HealthKitReporter.swift` (`QuantityResultsHandler`, `StatusCompletionBlock`, `SaveCompletionBlock`). A new callback shape gets a new documented typealias there, with labeled parameters.
* A callback reports either results or an error, never partial results with an error; empty results with no error mean "no data", never a failed cast or conversion (report `HealthKitError.invalidType` or `HealthKitError.parsingFailed` instead).
* Anchored queries hand back the anchor they started from on any error, so the next run delivers the same changes again.
* Error path in a result handler: `guard error == nil, let results = data else { handler([], error); return }`.
* Defaults mirror existing methods: `predicate: NSPredicate? = .allSamples`, `limit: Int = HKObjectQueryNoLimit`, sort by `HKSampleSortIdentifierStartDate` descending.
* Multi-step queries (e.g. ECG + voltage, heartbeat series) live in `Service/Retriever/<Name>Retriever.swift`.

### G. Example App (`Example/`)
* Programmatic UIKit, MVVM with Combine; no storyboards or XIBs except `LaunchScreen.xib`. `AppDelegate` creates the window and a `UINavigationController` with `DemoViewController`.
* `DemoViewModel` exposes an `Input` struct (subjects for user intents: tapped rows, launch) and an `Output` struct (subjects holding state: sections, per-row results, progress); the pipelines from input to output are built in `init`.
* `DemoViewController` installs `DemoView` in `loadView()` (`view = baseView`) and only binds the view model's output to the view and the view's events to the input. It never adds subviews itself.
* Views (`DemoView`, `DemoHeaderView`, `DemoCell`) declare each subview as a closure-initialized property that carries its own styling, and their initializers call `addSubviews()` then `makeConstraints()`.
* `HealthKitReporterService` exposes only `publisher(for:)`. It owns one `DemoPerformer` per library area (`ReaderDemos`, `WriterDemos`, …), each keeping its `HealthKitReporter` and any state (anchors, live queries) `private`.
* UI updates from HealthKit callbacks reach the main queue through `receive(on: DispatchQueue.main)` or `DispatchQueue.main.async`, with explicit `[unowned self]` / `[weak self]` captures.
* Authorization is built from the `allCases` of every type enum: reads leave out correlations (HealthKit authorizes their component types), writes keep the types whose `isWritable` is true, clinical records are requested separately (they start Health's records flow), and vision prescriptions and medications use per-object authorization.
* The watch companion (`Example/HealthKitReporterWatch`) uses SwiftUI, since watchOS has no UIKit; it handles `startWatchApp` and depends on the local package.
* Every new public library method gets a `DemoRow` and a demo in the matching `DemoPerformer`, and a usage snippet in `README.md`. A new type case is covered automatically by the `allCases`-driven authorization.

---

## 6. Testing Strategy & Execution Protocol

The codebase enforces test-first **TDD**. Code without tests will be rejected.

### A. Testing Categories & Toolstack

| Category | Target | Package | Purpose & Scope |
| :--- | :--- | :--- | :--- |
| **Payload Tests** | `Sources/Model/Payload/*` | `XCTest` | Round-trip every payload: create → `encoded()` → `JSONDecoder` decode, `make(from:)` from a dictionary shaped like the Flutter plugin sends it, and `uuid` kept by `make(from:)` / `copyWith`. |
| **Type Tests** | `Sources/Model/Type/*` | `XCTest` | `identifier`, `make(from:)` and `isWritable` for new cases. |
| **Service Tests** | `Sources/Service/*` | `XCTest` | Through the public API on the simulator. The test host has no HealthKit entitlement, so HealthKit answers every query and write with an error: test validation (`invalidType`, `invalidValue`), that every callback fires, and that calls reach HealthKit. |
| **Example App** | `Example/` | manual, device | Mapping real HealthKit data to payloads needs authorization and data; verify new reader/writer/observer APIs through the demo app on a device or simulator. |

### B. Test Conventions
* One `class <PayloadName>Tests: XCTestCase` per payload in `Tests/<PayloadName>Tests.swift`, `import HealthKitReporter` (public API only — no `@testable`). Service and query tests get one class per role or area.
* Name the object under test `sut`. Test names describe the flow: `testCreateThenEncodeThenDecode`, `testCreateFromDictionary`.
* Use fixed timestamps (`Date(timeIntervalSince1970: 1626884800)`), assert **every** field, and compare floating values with `accuracy:`.
* Test methods are `throws`; no `try!` / `do-catch` swallowing.

### C. Official CLI Commands

```bash
# 1. Run the library test suite on a simulator (SwiftPM package scheme) with coverage
xcodebuild test -scheme HealthKitReporter \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" \
  -enableCodeCoverage YES -resultBundlePath TestResults.xcresult \
  CODE_SIGNING_REQUIRED=NO
xcrun xccov view --report --only-targets TestResults.xcresult

# 2. Build for watchOS (needs the watchOS platform installed in Xcode)
xcodebuild build -scheme HealthKitReporter \
  -destination "generic/platform=watchOS Simulator" CODE_SIGNING_REQUIRED=NO

# 3. Lint Sources, Tests and Example — every violation fails
swiftlint lint --strict

# 4. Build the example app and its watch companion after a public API change
xcodebuild build -project Example/HealthKitReporter.xcodeproj \
  -scheme HealthKitReporter_Example \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" CODE_SIGNING_ALLOWED=NO
xcodebuild build -project Example/HealthKitReporter.xcodeproj \
  -scheme HealthKitReporterWatch \
  -destination "generic/platform=watchOS Simulator" CODE_SIGNING_ALLOWED=NO
```

`.github/workflows/ci.yml` runs all four on every PR and push to `master`, plus a version/changelog guard.
There is no lint baseline. An inline `swiftlint:disable` carries a comment with its reason.

### D. Test-First TDD Pipeline
1. **Coverage**: every payload, type and `Payload.make(from:)` path is covered. Code that only runs on HealthKit data (harmonize decorators, HK initializers, factories) can't be reached without the entitlement and is checked through the Example app.
2. **Cycle**:
  * 🔴 **Red**: Write a failing XCTest defining the specification *before* production code.
  * 🟢 **Green**: Write minimal production code to pass the test.
  * 🔵 **Refactor**: Clean up implementation details while ensuring tests stay green.

### E. Quality Gate Requirements
Before any commit or PR creation, the codebase must pass all gates:
1. `swiftlint` — **zero warnings or errors**.
2. `xcodebuild test` — **all tests green**; quote the executed/failed counts it prints.
3. watchOS build — passes (CI `Package` job; state "verified in CI only" when the watchOS platform isn't installed locally).
4. Example app builds — **required whenever public API changes**. Otherwise state "not applicable — no public API change" in the evidence line rather than omitting it: an unstated gate reads as a skipped one.
5. Coverage — `HealthKitReporter` line coverage reported by `xccov` is **≥ `COVERAGE_THRESHOLD`** in `.github/workflows/ci.yml` (CI `Package` job fails below it); quote the measured percentage. A PR that adds tests raises the threshold to its new measured level (rounded down to one decimal); never lower it.

---

## 7. Release & Versioning

* **SemVer**: breaking public API or dictionary-contract changes → major; new types/features → minor; fixes → patch.
* Releases are automated by release-please (`.github/workflows/release.yml`, `release-please-config.json`). It derives the bump from Conventional Commits on `master` and keeps a `chore: release X.Y.Z` PR open that bumps `.release-please-manifest.json`, prepends the `## [X.Y.Z] - dd.MM.yyyy.` entry to `CHANGELOG.md` and updates the `x-release-please-version` line in `README.md`.
* Merging the release PR creates the bare tag `X.Y.Z` (no `v` prefix) and the GitHub Release — that tag is the SwiftPM release. Never tag, bump versions or edit released `CHANGELOG.md` entries by hand.
* Commit messages are the changelog: write the summary for consumers.
* New public API is documented in `README.md` with a usage snippet.

---

## 8. Git & GitHub CLI (`gh`) Operational Protocols

### Branch Naming Convention
All branches MUST follow the strict user initials and issue structure:

```text
<initials>/issue-<XXX>
```

* **Example**: `vk/issue-14` or `ab/issue-102`

### GitHub CLI (`gh`) Operations

```bash
# View assigned issue context
gh issue view <issue_number>

# Create feature branch for issue (ALWAYS branch off a freshly pulled master)
git fetch origin
git switch master && git pull --ff-only origin master
git checkout -b <initials>/issue-<issue_number>

# Create Pull Request using gh CLI
gh pr create \
  --title "<type>(<scope>)[!]: <short summary>" \
  --body "## Summary
<description>

## Changes
- <file_path>: <details>

## Tests
- Summary: XCTest suite green, swiftlint clean, watchOS + Example builds passing."

Refs: #<issue>"

# Check PR checks and review status
gh pr status
gh pr checks
```

### Mandatory Git Execution Sequence
Before committing or creating a PR, run this exact sequence:

```bash
# 1. Lint
swiftlint lint --strict

# 2. Execute test suite
xcodebuild test -scheme HealthKitReporter \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" CODE_SIGNING_REQUIRED=NO

# 3. Build the Example app (public API changes)
xcodebuild build -project Example/HealthKitReporter.xcodeproj -scheme HealthKitReporter_Example \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" CODE_SIGNING_ALLOWED=NO

# 4. Inspect file status before staging
git status

# 5. Stage specific changed files intentionally (NO blind `git add .`)
git add Sources/Model/Payload/<Name>.swift Tests/<Name>Tests.swift

# 6. Commit using strict multi-paragraph format
git commit -m "<type>(<scope>)[!]: <short summary>" \
  -m "<longer description / context>" \
  -m "Changes:
- <file_path>: <details>
- <file_path>: <details>" \
  -m "Tests: <summary>" \
  -m "Refs: #<issue>"
```

### Commit Format Specification
```text
<type>(<scope>)[!]: <short summary>

<longer description / context>

Changes:
- <file path>: <details>
- <file path>: <details>

Tests: <summary>

[BREAKING CHANGE: <what breaks and how to migrate>]
Refs: #<issue>
```

* The header is a [Conventional Commit](https://www.conventionalcommits.org) — release-please parses it to pick the version bump and changelog section; a header in any other shape is silently left out of the release.
* `<type>`: `feat` (→ minor), `fix` (→ patch), or `docs`, `test`, `refactor`, `ci`, `build`, `chore` (no release). `!` after the scope or a `BREAKING CHANGE:` footer → major.
* `Refs: #<issue>` is required whenever an issue exists.

---

## 9. AI Verification Checklist

Before outputting code or submitting PRs, explicitly verify:
* [ ] Does every new file start with the Xcode header block and match the sibling files' style?
* [ ] Are singletons and static-only utility types absent, with `HKHealthStore` injected via `init`?
* [ ] Does the change follow the `Sources/{Decorator,Model,Service}` layout, one extended type per `Extensions+<Type>.swift`?
* [ ] Is new public API free of raw `HK*` types, with mapping in `Original` / `Harmonizable`?
* [ ] Do writes that act on stored samples look them up by `uuid`, and does every input HealthKit raises for get validated in Swift first?
* [ ] Is every API newer than iOS 15.0 / watchOS 8.0 gated by `@available` / `#available`, with a `HealthKitError.notAvailable` fallback?
* [ ] Are errors thrown only as `HealthKitError` cases with descriptive messages, without `fatalError`, `try!` or force casts?
* [ ] Does every conversion of HealthKit results report a failure (`converted`, `parsingFailed`) instead of skipping it with `try?` or `continue`, and do anchored queries keep the caller's anchor on errors?
* [ ] Does every new payload follow `Quantity.swift`: `Harmonized: Codable`, `public let` fields, memberwise `init`, `copyWith`, and `// MARK: -` extensions for `Original`, `Payload`, `Factory`?
* [ ] Are new enum cases handled in every exhaustive `switch`, with no `default:` over library enums?
* [ ] Are `Payload.make(from:)` keys and `Codable` names unchanged, or is the break versioned as major?
* [ ] Does every `public` declaration carry a doc comment in the `- Parameter` / `- Throws` / `- Returns` format?
* [ ] Are wrapped calls/declarations one-argument-per-line, and lines ≤ 110?
* [ ] Are `testCreateThenEncodeThenDecode` and `testCreateFromDictionary` (or equivalents) written first and green?
* [ ] Did `swiftlint` and `xcodebuild test` pass, the watchOS build pass, and the Example app build if public API changed?
* [ ] Were `README.md` and the Example app updated for user-visible changes, leaving `CHANGELOG.md` and versions to release-please?
* [ ] Does every new public method or type case have a demo in the Example app (a `DemoRow` for methods, `allCases` authorization for types)?
* [ ] Is the branch named strictly `<initials>/issue-<XXX>`?
* [ ] Are git commits made without `--no-verify` and staged without blind `git add .`?
* [ ] Was `gh pr create` used with structured title/body matching commit specs?
* [ ] Does the commit message carry the Conventional `<type>(<scope>)[!]: <summary>` header, a description, `Changes:`, `Tests:` and `Refs: #<issue>` (§8), with no AI trailer?
