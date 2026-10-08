# Contributing

When contributing to this repository, please first discuss the change you wish to make via an issue
with the owners of this repository before making a change.

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Pull Request Process

1. Branch off a freshly pulled `master` and keep one issue per pull request.
2. Write the tests first: every payload round-trips through `encoded()` and `make(from:)`, and new
   behavior gets a test through the public API (`import HealthKitReporter`, no `@testable`).
3. Update `README.md` with a usage snippet for new public API, and add a demo row for it to the
   Example app.
4. Use a [Conventional Commit](https://www.conventionalcommits.org) title (`feat:`, `fix:`, `docs:`, …;
   `!` for breaking changes). release-please derives the version and the `CHANGELOG.md` entry from it,
   so don't bump versions or edit released changelog entries by hand.
5. You may merge the Pull Request once you have the sign-off of another developer, or if you do not
   have permission to do that, you may request the second reviewer to merge it for you.

## Swift

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
SwiftLint enforces the style (`.swiftlint.yml`, lines ≤ 110 characters; `Tests/.swiftlint.yml` allows longer
test bodies). Every violation fails CI.

## Checks

CI runs these on every pull request; run them locally before pushing:

```bash
# Lint
swiftlint lint --strict

# Test on a simulator, with coverage (must stay ≥ COVERAGE_THRESHOLD in .github/workflows/ci.yml)
xcodebuild test -scheme HealthKitReporter \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" \
  -enableCodeCoverage YES -resultBundlePath TestResults.xcresult CODE_SIGNING_REQUIRED=NO
xcrun xccov view --report --only-targets TestResults.xcresult

# Build for watchOS
xcodebuild build -scheme HealthKitReporter \
  -destination "generic/platform=watchOS Simulator" CODE_SIGNING_REQUIRED=NO

# Build the Example app and its watch companion
xcodebuild build -project Example/HealthKitReporter.xcodeproj -scheme HealthKitReporter_Example \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" CODE_SIGNING_ALLOWED=NO
xcodebuild build -project Example/HealthKitReporter.xcodeproj -scheme HealthKitReporterWatch \
  -destination "generic/platform=watchOS Simulator" CODE_SIGNING_ALLOWED=NO
```
