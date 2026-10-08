# 3. Scope of workout and query wrappers

Date: 08.10.2026

## Status

Accepted

## Context

The audit listed HealthKit workout and query APIs the library doesn't wrap (G3, G4). HealthKitReporter turns HealthKit objects into plain, `Codable` payloads and back, mainly for the `health_kit_reporter` Flutter plugin, which talks to it through callbacks over a method channel. Each candidate API was weighed against that role.

## Decision

Wrapped:

- **Workout model (iOS 16+):** `Workout.statistics` and `Workout.activities` (`HKWorkoutActivity` as `WorkoutActivity`). The totals fall back to the summed statistics when the deprecated total properties are `nil`, as they are for activity-based workouts.
- **Workout writing:** `HealthKitWriter.saveWorkout(_:samples:route:completion:)` uses `HKWorkoutBuilder` and `HKWorkoutRouteBuilder`, so new workouts no longer depend on the deprecated `HKWorkout` initializer. `save(sample:)` keeps working for existing consumers.
- **Workout effort (iOS 18):** `workoutEffortRelationshipQuery` and `relateWorkoutEffort` / `unrelateWorkoutEffort`.
- **Queries and store:** `HKQueryDescriptor` for sample, anchored and observer queries; `HKQuantitySeriesSampleQuery`; the quantity and heartbeat series builders; `getRequestStatusForAuthorization`; `earliestPermittedSampleDate`; `recalibrateEstimates`; `HKAttachmentStore`; and the `.separateBySource` and `.duration` statistics options.

Not wrapped:

- **Live workout sessions** (`HKWorkoutSession`, `HKLiveWorkoutBuilder`, session mirroring). They drive a workout while it happens: sensors, the session state machine, and a watch app that keeps running in the background. That belongs in an app's workout controller, not in a library that reports data already in Health. Reports of finished sessions already work through `saveWorkout` and the workout queries.
- **Swift async/await variants.** The main consumer is callback based, and duplicating every method as `async` would double the public API. Swift consumers can wrap a callback with `withCheckedThrowingContinuation`. If added later, async variants should cover the whole API in one major release, not individual methods.

## Consequences

- Workouts read on iOS 16+ carry per-type statistics and multi-sport activities; consumers on older JSON keep decoding because the new fields are optional.
- The builder save can't be exercised by unit tests: the test host has no HealthKit entitlement, and `beginCollection` never calls back without one. It is verified through the Example app on a device.
- Live sessions and async/await stay out of scope until a consumer needs them; this record is the place to revisit that.
