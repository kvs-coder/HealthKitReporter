# AGENTS.md — System & AI Agent Directives

> **Library Mission**: HealthKitReporter is a Swift wrapper around Apple's **HealthKit** framework, distributed via **CocoaPods** and **Swift Package Manager** (iOS 9+, watchOS 2+).
> It turns `HK*` objects into plain, `Codable` payload structs (and back), so consumers — including the `health_kit_reporter` Flutter plugin — can read, write and observe Apple Health data without touching HealthKit types directly.
> `Example/` hosts a UIKit demo app that exercises the public API end to end.

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
├── HealthKitReporter.swift          (facade + public typealiases for query handlers)
├── HealthKitError.swift             (the single public error enum)
├── Decorator/
│   └── Extensions+<TypeName>.swift  (one extended type per file)
├── Model/
│   ├── <Protocol>.swift             (Harmonizable, Original, Payload, UnitConvertable, ...)
│   ├── Payload/
│   │   └── <PayloadName>.swift      (Quantity, Category, Workout, ...)
│   └── Type/
│       ├── <TypeName>.swift         (ObjectType, CharacteristicType, ...)
│       └── Sample/
│           └── <SampleTypeName>.swift
└── Service/
    ├── HealthKit<Role>.swift        (Reader, Writer, Observer, Manager)
    └── Retriever/
        └── <Name>Retriever.swift    (multi-step query helpers)

Tests/
└── <PayloadName>Tests.swift         (one XCTestCase per payload)

Example/
├── HealthKitReporter/               (UIKit demo app: AppDelegate, ViewController, HealthKitReporterService)
├── Tests/
└── Podfile
```

### Layer Invariants
* **No HK leakage**: Public API takes and returns library types (`QuantityType`, `Quantity`, `Query` typealiases). Raw `HK*` objects stay `internal` behind `Original` / `Harmonizable`.
* **One store**: `HealthKitReporter.init()` builds one `HKHealthStore` and injects it into every service. Services never create their own.
* **Decorators are internal glue**: `Extensions+*.swift` hold conversions and helpers; they never run queries.

---

## 4. Strict Prohibitions & Bans

### Architecture & Code Bans
* ❌ **Ban on Singletons**: No `static let shared`, global instances or factory singletons. Consumers instantiate `HealthKitReporter()`; dependencies are passed through `init`.
  * **Not covered** — stateless static queries of the platform (`HealthKitReporter.isHealthDataAvailable`) and static factories on payloads/types (`Quantity.make(from:)`, `ObjectType.make(from:)`, `Quantity.collect(...)`).
* ❌ **Ban on Static-Only Utility Types**: No `enum`/`struct`/`class` that only namespaces `static` helper functions. Put behavior in an extension of the type it belongs to (`Extensions+Double.swift` → `Double.asDate`).
* ❌ **Ban on Exposing `HK*` Types in New Public API**: New public methods and payload fields use library types; mapping happens in `Original.asOriginal()` and `Harmonizable.harmonize()`.
* ❌ **Ban on Unguarded Availability**: Every API newer than the deployment target (iOS 9.0) MUST be gated with `@available(iOS X, *)` on the declaration or `if #available(iOS X, *)` at the call site, with an `else` that throws `HealthKitError.notAvailable("\(type) is not available for the current iOS")` or degrades gracefully.
* ❌ **Ban on Ad-hoc Errors**: Throw only `HealthKitError` cases with a descriptive message (`HealthKitError.invalidType("Invalid HKQuantityType: \(type)")`). No new error types, no `NSError`.
* ❌ **Ban on `fatalError` / `try!` / Force Casts in New Code**: Use `guard ... else { throw HealthKitError... }`. Existing `@unknown default: fatalError()` arms are legacy, not precedent.
* ❌ **Ban on Catch-all Switches over Library Enums**: A `switch` over `QuantityType`, `CategoryType`, etc. lists every case; no `default:`. `@unknown default` is required only for Apple's non-frozen enums.
* ❌ **Ban on Mutable Payloads**: Payload fields are `public let`. Changes go through `copyWith(...)`.
* ❌ **Ban on Breaking the Dictionary Contract**: `Payload.make(from:)` keys and `Codable` property names are consumed by the Flutter plugin. Renaming one is a breaking change (major SemVer bump + `CHANGELOG.md` entry).
* ❌ **Ban on Hardcoded Units in Payloads**: Units are `String`s produced by `HKUnit.unitString` and parsed with `HKUnit(from:)`; SI defaults live only in `HKQuantitySample.harmonize()`.

### Git & VCS Bans
* ❌ **Ban on `git commit --no-verify`**: Bypassing pre-commit git hooks, static analysis, or test suites is forbidden.
* ❌ **Ban on Blind Staging (`git add .` / `git add -A`)**: Run `git status` first and stage only relevant source, test, and config files explicitly.
* ❌ **Ban on Direct Force Pushing**: Force pushing to `master` is forbidden. Use `--force-with-lease` on isolated feature branches only when necessary.
* ❌ **Ban on Single-Line Shortcut Commits**: Omitting the detailed description, `Changes:`, and `Tests:` sections in commit messages is strictly forbidden.
* ❌ **Ban on AI Attribution Trailers**: A commit message MUST NEVER carry `Co-Authored-By: <Model Name> <noreply@anthropic.com>`, or any other trailer crediting an AI model or tool.
* ❌ **Ban on Committing User or Build State**: Never commit `xcuserdata/`, `DerivedData`, `build/`, `.swiftpm/xcode/xcuserdata/` or a generated `HealthKitReporter.xcodeproj`. `Example/Pods/` is tracked on purpose — change it only via `pod install`.

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

* **Indentation**: 4 spaces. Line length ≤ 110 (`.swiftlint.yml`).
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
* `original: HKObjectType?` maps each case with an exhaustive `switch`, returning `nil` under an `#available` guard for unsupported OS versions.
* `identifier` derives from `original?.identifier`; lookup by string goes through `ObjectType.make(from:)`.
* Adding a case means updating **every** exhaustive switch over it (e.g. `HKQuantitySample.harmonize()` unit mapping) and the `CHANGELOG.md`.

### D. Payloads (`Sources/Model/Payload/`)
A payload is a `public struct` that mirrors one `HK*` class. Follow `Quantity.swift` exactly:
1. Nested `public struct Harmonized: Codable` for the value part (value, unit, metadata) with a public memberwise `init` and `copyWith`.
2. `public let` fields (`uuid`, `identifier`, `startTimestamp`, `endTimestamp`, `device`, `sourceRevision`, `harmonized`). Dates are `Double` seconds since 1970.
3. `internal init(<hkName>: HK...) throws` from the HealthKit object.
4. `public init(...)` memberwise (generates a new `uuid`) + `public func copyWith(...)` with every parameter `= nil` and `?? self.<field>` fallbacks.
5. Extensions, each behind a `// MARK: -`:
   * `Original` — `asOriginal() throws -> HK...`, `guard` + `HealthKitError.invalidType` on bad identifiers.
   * `Payload` — `static func make(from dictionary: [String: Any]) throws -> Self`; numbers read as `NSNumber` and converted with `Double(truncating:)`; missing required keys throw `HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")`; plus `collect(from array: [Any])`.
   * `Factory` — `static func collect(results: [HKSample]...) -> [Self]` that skips (`continue`) samples failing to convert.

### E. Decorators (`Sources/Decorator/`)
* One file per extended type: `Extensions+<TypeName>.swift`.
* `HK*` sample extensions conform to `Harmonizable` (`typealias Harmonized = <Payload>.Harmonized`; `func harmonize() throws -> Harmonized`).
* Helpers that are pure conversions are computed properties (`asDate`, `asMetadata`, `asOriginal`).

### F. Services (`Sources/Service/`)
* `public class HealthKit<Role>` with a single `private let healthStore: HKHealthStore` injected via `internal init(healthStore:)`.
* **Query builders** (`HealthKitReader`) validate input, build and **return** a `Query` — they never execute it. The consumer runs it with `manager.executeQuery(_:)`.
* Callbacks use the public typealiases declared in `HealthKitReporter.swift` (`QuantityResultsHandler`, `StatusCompletionBlock`). A new callback shape gets a new documented typealias there, with labeled parameters.
* Error path in a result handler: `guard error == nil, let results = data else { handler([], error); return }`.
* Defaults mirror existing methods: `predicate: NSPredicate? = .allSamples`, `limit: Int = HKObjectQueryNoLimit`, sort by `HKSampleSortIdentifierStartDate` descending.
* Multi-step queries (e.g. ECG + voltage, heartbeat series) live in `Service/Retriever/<Name>Retriever.swift`.

### G. Example App (`Example/`)
* UIKit + storyboard. `ViewController` holds UI only (`@IBOutlet`, `@IBAction`) and delegates every HealthKit call to `HealthKitReporterService`.
* `HealthKitReporterService` is a `final class` owning `private var reporter: HealthKitReporter?`, created only when `HealthKitReporter.isHealthDataAvailable`.
* UI updates from HK callbacks hop to `DispatchQueue.main.async` and capture `[unowned self]` / `[weak self]` explicitly.
* Every new public library feature gets a demo method in `HealthKitReporterService` wired to a button, and a usage snippet in `README.md`.

---

## 6. Testing Strategy & Execution Protocol

The codebase enforces test-first **TDD**. Code without tests will be rejected.

### A. Testing Categories & Toolstack

| Category | Target | Package | Purpose & Scope |
| :--- | :--- | :--- | :--- |
| **Payload Tests** | `Sources/Model/Payload/*` | `XCTest` | Round-trip every payload: create → `encoded()` → `JSONDecoder` decode, and `make(from:)` from a dictionary shaped like the Flutter plugin sends it. |
| **Type Tests** | `Sources/Model/Type/*` | `XCTest` | `identifier` / `original` / `make(from:)` mapping for new cases. |
| **Example App** | `Example/` | manual, device | HealthKit queries need a real store and authorization; verify new reader/writer/observer APIs through the demo app on a device or simulator. |

### B. Test Conventions
* One `class <PayloadName>Tests: XCTestCase` per payload in `Tests/<PayloadName>Tests.swift`, `import HealthKitReporter` (public API only — no `@testable`).
* Name the object under test `sut`. Test names describe the flow: `testCreateThenEncodeThenDecode`, `testCreateFromDictionary`.
* Use fixed timestamps (`Date(timeIntervalSince1970: 1626884800)`), assert **every** field, and compare floating values with `accuracy:`.
* Test methods are `throws`; no `try!` / `do-catch` swallowing.

### C. Official CLI Commands

```bash
# 1. Run the library test suite on a simulator (SwiftPM package scheme)
xcodebuild test -scheme HealthKitReporter \
  -destination "platform=iOS Simulator,name=iPhone 15,OS=latest" \
  CODE_SIGNING_REQUIRED=NO

# 2. Lint the Swift sources
swiftlint lint Sources Tests

# 3. Validate the CocoaPods spec (same as the Lint Pod CI job)
bundle exec pod lib lint HealthKitReporter.podspec --allow-warnings

# 4. Build the example app after a public API change
cd Example && bundle exec pod install && xcodebuild build \
  -workspace HealthKitReporter.xcworkspace -scheme HealthKitReporter_Example \
  -destination "platform=iOS Simulator,name=iPhone 15,OS=latest"
```

### D. Test-First TDD Pipeline
1. **Coverage**: every payload, type and `Payload.make(from:)` path is covered; target **100%** for `Model/`.
2. **Cycle**:
  * 🔴 **Red**: Write a failing XCTest defining the specification *before* production code.
  * 🟢 **Green**: Write minimal production code to pass the test.
  * 🔵 **Refactor**: Clean up implementation details while ensuring tests stay green.

### E. Quality Gate Requirements
Before any commit or PR creation, the codebase must pass all gates:
1. `swiftlint` — **zero new warnings or errors** in touched files.
2. `xcodebuild test` — **all tests green**; quote the executed/failed counts it prints.
3. `pod lib lint` — passes (mirrors `.github/workflows/lint_pod.yml`).
4. Example app builds — **required whenever public API changes**. Otherwise state "not applicable — no public API change" in the evidence line rather than omitting it: an unstated gate reads as a skipped one.

---

## 7. Release & Versioning

* **SemVer**: breaking public API or dictionary-contract changes → major; new types/features → minor; fixes → patch.
* A release bumps `s.version` in `HealthKitReporter.podspec`, adds a `## [X.Y.Z] - dd.MM.yyyy.` entry with `*` bullets on top of `CHANGELOG.md`, and updates version references in `README.md`.
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
  --title "<type> #<issue> (<scope>): <short summary>" \
  --body "## Summary
<description>

## Changes
- <file_path>: <details>

## Tests
- Summary: XCTest suite green, swiftlint clean, pod lib lint passing."

# Check PR checks and review status
gh pr status
gh pr checks
```

### Mandatory Git Execution Sequence
Before committing or creating a PR, run this exact sequence:

```bash
# 1. Lint
swiftlint lint Sources Tests

# 2. Execute test suite
xcodebuild test -scheme HealthKitReporter \
  -destination "platform=iOS Simulator,name=iPhone 15,OS=latest" CODE_SIGNING_REQUIRED=NO

# 3. Validate podspec
bundle exec pod lib lint HealthKitReporter.podspec --allow-warnings

# 4. Inspect file status before staging
git status

# 5. Stage specific changed files intentionally (NO blind `git add .`)
git add Sources/Model/Payload/<Name>.swift Tests/<Name>Tests.swift CHANGELOG.md

# 6. Commit using strict multi-paragraph format
git commit -m "<type> #<issue> (<scope>): <short summary>" \
  -m "<longer description / context>" \
  -m "Changes:
- <file_path>: <details>
- <file_path>: <details>" \
  -m "Tests: <summary>"
```

### Commit Format Specification
```text
<type> #<issue> (<scope>): <short summary>

<longer description / context>

Changes:
- <file path>: <details>
- <file path>: <details>

Tests: <summary>
```

---

## 9. AI Verification Checklist

Before outputting code or submitting PRs, explicitly verify:
* [ ] Does every new file start with the Xcode header block and match the sibling files' style?
* [ ] Are singletons and static-only utility types absent, with `HKHealthStore` injected via `init`?
* [ ] Does the change follow the `Sources/{Decorator,Model,Service}` layout, one extended type per `Extensions+<Type>.swift`?
* [ ] Is new public API free of raw `HK*` types, with mapping in `Original` / `Harmonizable`?
* [ ] Is every API newer than iOS 9.0 gated by `@available` / `#available`, with a `HealthKitError.notAvailable` fallback?
* [ ] Are errors thrown only as `HealthKitError` cases with descriptive messages, without `fatalError`, `try!` or force casts?
* [ ] Does every new payload follow `Quantity.swift`: `Harmonized: Codable`, `public let` fields, memberwise `init`, `copyWith`, and `// MARK: -` extensions for `Original`, `Payload`, `Factory`?
* [ ] Are new enum cases handled in every exhaustive `switch`, with no `default:` over library enums?
* [ ] Are `Payload.make(from:)` keys and `Codable` names unchanged, or is the break versioned as major?
* [ ] Does every `public` declaration carry a doc comment in the `- Parameter` / `- Throws` / `- Returns` format?
* [ ] Are wrapped calls/declarations one-argument-per-line, and lines ≤ 110?
* [ ] Are `testCreateThenEncodeThenDecode` and `testCreateFromDictionary` (or equivalents) written first and green?
* [ ] Did `swiftlint`, `xcodebuild test` and `pod lib lint` pass, and did the Example app build if public API changed?
* [ ] Were `CHANGELOG.md`, `README.md` and the Example app updated for user-visible changes?
* [ ] Is the branch named strictly `<initials>/issue-<XXX>`?
* [ ] Are git commits made without `--no-verify` and staged without blind `git add .`?
* [ ] Was `gh pr create` used with structured title/body matching commit specs?
* [ ] Does the commit message carry the `<type> #<issue> (<scope>): <summary>` header, a description, `Changes:` and `Tests:` (§8), with no AI trailer?
