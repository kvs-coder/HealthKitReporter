# 4. Contract changes for the next major release

Date: 08.10.2026

## Status

Accepted. Ships as one major release of HealthKitReporter together with a release of the `health_kit_reporter` Flutter plugin.

## Context

The `health_kit_reporter` Flutter plugin consumes the payloads as JSON from `encoded()` and sends dictionaries back to `make(from:)`. Renaming a key or changing the meaning of a value breaks it. The audit found several outputs that were wrong but already part of that contract:

- metadata with mixed value types was dropped, and the JSON nested values as `{"string": {"dictionary": ...}}` (C3);
- vision prescription dates were milliseconds while every other payload date is seconds (W4);
- negative infinity was encoded as `"inf"` and NaN as `"-500.0"` (S2);
- several description strings were misspelled (S5).

Fixing each one changes what consumers read.

## Decision

Fix all of them in one major release instead of spreading breaking changes over several:

| Change | Before | After |
| :--- | :--- | :--- |
| Metadata shape (ADR 0002) | `{"string": {"dictionary": {...}}}`, one value type per dictionary | flat object; strings, numbers, booleans, `{"timestamp"}` dates, `{"value", "unit"}` quantities |
| Vision prescription dates | milliseconds since 1970 | seconds since 1970 |
| Non-finite numbers | `"inf"` for both infinities, `"-500.0"` for NaN | `"Infinity"`, `"-Infinity"`, `"NaN"` |
| Descriptions | "Pickerball", "Handy Cycling", "Prepare and Recovery", "Sinus rhytm", "Pause on resume request" | "Pickleball", "Hand Cycling", "Preparation and Recovery", "Sinus rhythm", "Pause or resume request" |

Each change is committed as `feat!` / `fix!` with a `BREAKING CHANGE:` footer, so release-please bumps the major version.

The decoding of symptom samples with the severity enum (W7) also changes `description` / `detail` strings. It is shipped as a fix, because the previous strings were wrong for every value but "not present".

New fields added in the same release (statistics duration and per-source values, activity summary move time, workout statistics and activities, vision prescription lenses) are optional, so older JSON keeps decoding.

## Consequences

- One coordinated upgrade for Flutter consumers, with a single migration list.
- The Flutter plugin must, in its matching release: read and send the flat metadata object; stop dividing vision prescription dates by 1000; parse `"Infinity"`, `"-Infinity"` and `"NaN"` in numeric fields; and update any comparisons against the old description strings.
- The library release must not be published before the plugin release is ready, or plugin users get the new JSON with the old parser.
