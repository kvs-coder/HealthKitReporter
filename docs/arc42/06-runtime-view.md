# 6. Runtime View

## 6.1 Authorization

```mermaid
sequenceDiagram
    participant Consumer
    participant M as HealthKitManager
    participant S as HKHealthStore
    Consumer->>M: requestAuthorization(toRead:toWrite:completion:)
    M->>M: map ObjectType → internal HKObjectType<br/>(unavailable → invalidType)
    M->>S: requestAuthorization(toShare:read:)
    S-->>Consumer: completion(success, error)
```

HealthKit never reveals whether *read* access was granted; `authorizationRequestStatus` only tells whether the sheet
would be shown. `HealthKitWriter.isAuthorizedToWrite(type:)` reports write access.

## 6.2 Read — build, then execute

```mermaid
sequenceDiagram
    participant Consumer
    participant R as HealthKitReader
    participant M as HealthKitManager
    participant S as HKHealthStore
    participant F as Quantity.collect
    Consumer->>R: quantityQuery(type:unit:predicate:resultsHandler:)
    R->>R: internal HKQuantityType of the type<br/>else throw invalidType
    R->>R: compatibleUnit(from: unit)<br/>else throw invalidValue
    R-->>Consumer: QueryHandle (not running)
    Consumer->>M: executeQuery(query)
    M->>S: execute(query)
    S->>R: results / error (background queue)
    alt error or no data
        R-->>Consumer: resultsHandler([], error)
    else results
        R->>F: collect(results:unit:)
        F->>F: per sample: harmonize()<br/>skip samples that fail
        R-->>Consumer: resultsHandler([Quantity], nil)
    end
```

The same shape applies to category, workout, correlation, statistics, anchored and series queries. Input errors
throw synchronously at build time; HealthKit errors arrive in the handler. Anchored queries return an `Anchor`
(a `Codable` wrapper of the archived `HKQueryAnchor`) that the consumer passes to the next run.

## 6.3 Write

1. The consumer builds a payload (memberwise `init` or `make(from:)` from a Flutter dictionary).
2. `HealthKitWriter.save(sample:)` / `addQuantity(...)` calls `asOriginal()`, which resolves the identifier, parses the
   unit and metadata, and throws `HealthKitError.invalidType` / `invalidValue` on bad input.
3. The resulting `HKSample` is saved to the store; `StatusCompletionBlock(success, error)` is always called.

Workouts (ADR 0003) use `saveWorkout(_:samples:route:completion:)`: `HKWorkoutBuilder` begins collection, adds
samples, ends collection, finishes the workout, then an `HKWorkoutRouteBuilder` attaches the route; the handler
receives the saved `Workout` payload.

## 6.4 Observe and background delivery

```mermaid
sequenceDiagram
    participant Consumer
    participant O as HealthKitObserver
    participant M as HealthKitManager
    participant S as HKHealthStore
    Consumer->>O: observerQuery(type:updateHandler:)
    O-->>Consumer: QueryHandle
    Consumer->>M: executeQuery(query)
    Consumer->>O: enableBackgroundDelivery(type:frequency:)
    O->>S: enableBackgroundDelivery
    Note over S: data changes in Health
    S->>O: (query, completion, error)
    O-->>Consumer: updateHandler(query, identifier, error, completion)
    Consumer->>Consumer: fetch changes (e.g. anchored query)
    Consumer->>S: completion()
```

The `ObserverCompletionUpdateHandler` variant hands HealthKit's completion to the consumer, who must call it after
processing — also on the error path — or HealthKit throttles background delivery. The plain `ObserverUpdateHandler`
variant calls it immediately after the handler returns.

## 6.5 Multi-step retrieval (ECG with voltages)

```mermaid
sequenceDiagram
    participant Consumer
    participant E as ElectrocardiogramRetriever
    participant C as SampleResultsCollector
    participant S as HKHealthStore
    Consumer->>S: executeQuery(electrocardiogramQuery handle)
    S->>E: [HKElectrocardiogram]
    E->>C: init(label:count: n)
    loop each sample i
        E->>C: enter()
        E->>S: execute(HKElectrocardiogramQuery(sample))
        S->>E: .measurement ... .done | .error
        E->>C: finish(i, ecg) | fail(i, error)
    end
    C-->>Consumer: notify → ([Electrocardiogram] in sample order, first error)
```

`SampleResultsCollector` serializes writes from concurrent HealthKit callbacks on a private queue, keeps results in
sample order and reports the first failure. Heartbeat series and workout routes use the same collector via
`SeriesSampleRetriever`.

## 6.6 Chained lookup (routes of one workout)

```mermaid
sequenceDiagram
    participant Consumer
    participant R as HealthKitReader
    participant T as StoredSampleRetriever
    participant Q as SeriesSampleRetriever
    participant S as HKHealthStore
    Consumer->>R: workoutRouteQuery(workoutUUID:limit:resultsHandler:)
    R->>T: makeStoredSamplesQuery(workoutType, [uuid])
    R-->>Consumer: QueryHandle (lookup, not running) | throws invalidValue
    Consumer->>S: executeQuery(handle)
    S->>T: [HKWorkout] | error
    alt workout found
        T->>Q: makeWorkoutRouteQuery(predicateForObjects(from: workout))
        Q->>S: execute(route query) → per-route HKWorkoutRouteQuery (6.5)
        Q-->>Consumer: resultsHandler([WorkoutRoute], first error)
    else not stored / HealthKit error
        T-->>Consumer: resultsHandler([], invalidIdentifier | error)
    end
```

The handle wraps the lookup only; `stopQuery` before the workout is found stops the chain, afterwards the route
queries run to the end (ADR 0006).
