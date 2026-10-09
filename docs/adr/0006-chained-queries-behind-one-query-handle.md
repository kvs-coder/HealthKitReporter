# 6. Chained queries behind one query handle

Date: 09.10.2026

## Status

Accepted. Additive, released in 4.1.0; extends ADR 0005.

## Context

The `health_kit_reporter` Flutter plugin needs the routes of one workout. HealthKit finds them with `HKQuery.predicateForObjects(from: workout)`, which takes the stored `HKWorkout`, so the reader has to look the workout up by its uuid first (as `StoredSampleRetriever` does for writes) and only then query its routes. That lookup is asynchronous, yet reader methods build a query and return one `QueryHandle` (ADR 0005) that `executeQuery` and `stopQuery` act on. A `QueryHandle` wraps exactly one `HKQuery`.

Options:

1. Run the lookup inside the reader method and hand back the route query later through a callback. The method would execute HealthKit work before the consumer calls `executeQuery`, breaking "query builders, not query runners" and the `QueryHandle` return.
2. Let `QueryHandle` hold several queries, or a mutable "current" query. Adds state and races to a type that today exposes only identity.
3. The handle wraps the first step, the workout lookup; its handler builds and executes the route query on the same store.

## Decision

Option 3. `reader.workoutRouteQuery(workoutUUID:limit:resultsHandler:)` validates the uuid at build time (malformed → throws `HealthKitError.invalidValue`), returns a handle wrapping the lookup `HKSampleQuery` built by `StoredSampleRetriever.makeStoredSamplesQuery`, and in that query's handler runs `SeriesSampleRetriever.makeWorkoutRouteQuery` with `HKQuery.predicateForObjects(from: workout)`. No stored workout → `HealthKitError.invalidIdentifier` in the handler; HealthKit errors pass through.

This is the shape the electrocardiogram, heartbeat series and route retrievers already have: the handle wraps the first query and follow-up queries run on the store from its handler.

## Consequences

- `QueryHandle` stays a single-query, identity-only type; `executeQuery` / `stopQuery` need no change.
- `stopQuery` before the workout is found stops the whole chain. After that, the follow-up queries are one-shot sample queries that run to the end and report once; stopping then has no effect.
- Further chained reader queries (e.g. samples of one workout) follow the same pattern.
