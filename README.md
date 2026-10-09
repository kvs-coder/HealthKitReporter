# HealthKitReporter

## About

A wrapper above HealthKit Apple's framework for data manipulations.
The library supports manipulating with values from HealthKit repository and translating them to <i>Codable</i> models allowing to encode the result as a simple JSON payload.
In addition you can write your own HealthKit objects using <i>Codable</i> wrappers which will be translated to <i>HKObjectType</i> objects inside HealthKit repository.

## Start

### Preparation

At first in your app's entitlements select HealthKit.
If you want to read Clinical Records then also check "Clinical Health Records" under Health Kit.
***NOTE:*** *You can only tick the "Clinical Health Records" checkmark if your development team has a paid Apple developer subscription. To test on a real device, or to publish your application, you will need a paid Apple subscription, but you can still test on the iOS simulator without a subscription by setting the Development Team to None.*

Then in your app's info.plist file add permissions:

```xml
<key>NSHealthShareUsageDescription</key>
<string>WHY_YOU_NEED_TO_SHARE_DATA</string>
<key>NSHealthUpdateUsageDescription</key>
<string>WHY_YOU_NEED_TO_USE_DATA</string>
```

If you plan to use **WorkoutRoute** **Series** please provide additionally CoreLocation permissions:

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>WHY_YOU_NEED_TO_ALWAYS_SHARE_LOCATION</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>WHY_YOU_NEED_TO_SHARE_LOCATION</string>
```

If you plan to read **Clinical Records** please provide additionally:

```xml
<key>NSHealthClinicalHealthRecordsShareUsageDescription</key>
<string>WHY_YOU_NEED_TO_SHARE_DATA</string>
```


### Common usage

Check `HealthKitReporter.isHealthDataAvailable` first: it is false on devices without Apple Health, e.g. some iPads. Then create a <i>HealthKitReporter</i> instance; keep it alive as long as its queries run.

The reporter instance contains several properties:
* reader
* writer
* manager
* observer

Every property is responsible for an appropriate part of HealthKit framework. Based from the naming, reader will handle every manipulation regarding reading data and writer will handle everything related to writing data in HealthKit repository, observer will handle observations and will notify if anything was changes in HealthKit, manager is responsible for the authorization of read/write types and launching a WatchApp you make.

If you want to read, write data or observe data changes, you always need to be sure that the data types are authorized to be read/written/observed. In that case manager has authorization method with completion block telling about the presentation of the authorization window. Notice that Apple Health Kit will show this window only once during the whole time app is installed on the device, in this case if some types were denied to be read or written, user should manually allow this in Apple Health App.

In examples below every operation is happening inside the authorization block. It is recommended to do so, because if new type will be added, there will be thrown a permission exception. If you are sure that no new types will appear, you can call operations outside authorization block in your app, only if the type's data reading/writing permissions were granted.

### Reading Data
Create a <i>HealthKitReporter</i> instance.

Authorize desired types to read, like step count.

If authorization was successful (the authorization window was shown) call a quantity query with type step count; it returns a **QueryHandle**.

Use reporter's **manager's** _executeQuery_ to execute the query. (Or _stopQuery_ to stop)

```swift
guard HealthKitReporter.isHealthDataAvailable else { return }
let reporter = HealthKitReporter()
let types = [QuantityType.stepCount]
reporter.manager.requestAuthorization(
    toRead: types,
    toWrite: types
) { (success, error) in
    if success && error == nil {
        reporter.manager.preferredUnits(for: types) { (preferredUnits, error) in
            if error == nil {
                for preferredUnit in preferredUnits {
                    do {
                        let query = try reporter.reader.quantityQuery(
                            type: try QuantityType.make(from: preferredUnit.identifier),
                            unit: preferredUnit.unit
                        ) { (results, error) in
                            if error == nil {
                                for element in results {
                                    do {
                                        print(try element.encoded())
                                    } catch {
                                        print(error)
                                    }
                                }
                            } else {
                                print(error)
                            }
                        }
                        reporter.manager.executeQuery(query)
                    } catch {
                        print(error)
                    }
                }
            } else {
                print(error)
            }
        }
    } else {
        print(error)
    }
}
```

Here is a sample response for steps:

```json

{
  "uuid" : "8B1F9C1E-4E0A-4C38-9D57-1B2F4A6C7D10",
  "sourceRevision" : {
    "productType" : "iPhone8,1",
    "systemVersion" : "14.0.0",
    "source" : {
      "name" : "Guy’s iPhone",
      "bundleIdentifier" : "com.apple.health.47609E07-490D-4E5F-8E68-9D8904E9BA08"
    },
    "version" : "14.0",
    "operatingSystem" : {
      "majorVersion" : 14,
      "minorVersion" : 0,
      "patchVersion" : 0
    }
  },
  "harmonized" : {
    "value" : 298,
    "unit" : "count"
  },
  "device" : {
    "softwareVersion" : "14.0",
    "manufacturer" : "Apple Inc.",
    "model" : "iPhone",
    "name" : "iPhone",
    "hardwareVersion" : "iPhone8,1"
  },
  "endTimestamp" : 1601066077.5886581,
  "identifier" : "HKQuantityTypeIdentifierStepCount",
  "startTimestamp" : 1601065755.8829093
}
```

Metadata encodes as a flat object. Strings, numbers and booleans are plain JSON values, a date is `{"timestamp": <seconds since 1970>}` and a quantity is `{"value": <number>, "unit": <unit>}`:

```json
"metadata" : {
  "HKTimeZone" : "Europe/Berlin",
  "HKWasUserEntered" : true,
  "HKHeartRateEventThreshold" : { "value" : 120, "unit" : "count/min" }
}
```

Timestamps are seconds since 1970. JSON has no infinity or NaN, so `encoded()` writes non-finite numbers as the strings `"Infinity"`, `"-Infinity"` and `"NaN"`, which Dart's `double.parse` and JavaScript's `Number` accept.

### Queries and anchors

Reader and observer methods return a `QueryHandle`. Run it with `manager.executeQuery(_:)` and stop long-lived queries with `manager.stopQuery(_:)`. Anchored queries hand back an `Anchor`, which encodes as a base64 string, so it can be stored and passed to the next run to receive only the changes:

```swift
let query = try reporter.reader.anchoredObjectQuery(type: QuantityType.stepCount, anchor: savedAnchor) { _, samples, deleted, anchor, error in
    savedAnchor = anchor // e.g. persist try anchor?.encoded()
}
reporter.manager.executeQuery(query)
```

### Statistics collections

`statisticsCollectionQuery` with a `resultsHandler` delivers whole batches: every interval from `enumerateFrom` to `enumerateTo` (now by default) once, then, with `monitorUpdates`, only the intervals each update changed.

```swift
let query = try reporter.reader.statisticsCollectionQuery(
    type: .stepCount,
    unit: "count",
    anchorDate: anchorDate,
    enumerateFrom: weekAgo,
    intervalComponents: DateComponents(day: 1),
    monitorUpdates: true
) { statistics, error in
    // one call per batch; replace the days it contains
    print(statistics.map { $0.harmonized.summary ?? 0 })
}
reporter.manager.executeQuery(query)
```

### Writing Data

Activity summaries, ECGs, clinical and verifiable records and medications are read-only: HealthKit doesn't let apps write them, so `save` completes with `HealthKitError.invalidType` for them. Heartbeat series and workout routes are written through their own methods, `saveHeartbeatSeries` and `saveWorkout(_:samples:route:)`, not through `save`.

***NOTE:*** *Clinical Records are read only, Health Kit does not allow writing any data to Clinical Records.*

Create a <i>HealthKitReporter</i> instance.

Authorize desired types to write, like step count. Only types whose `isWritable` is true can be requested for writing; HealthKit computes the others itself (e.g. `QuantityType.appleExerciseTime`, ECGs). Correlations and per-object types (vision prescriptions, medications) can't go into `requestAuthorization` either. For all of these the completion reports `HealthKitError.invalidType` instead of HealthKit crashing the app. Requesting heartbeat series or workout routes also requests the heart rate variability and workout types HealthKit requires with them. `HealthKitError` is a `LocalizedError`, so `localizedDescription` shows its message:

```swift
let writable = QuantityType.allCases.filter(\.isWritable)
```

Saving checks the payload first, too: a sample that ends before it starts, a category value its type doesn't know, or an unknown workout event type completes with `HealthKitError.invalidValue` / `invalidType`.

You may call manager's <i>preferredUnits(for: )</i> function to pass units (for <b>Quantity Types</b>).

If authorization was successful (the authorization window was shown) call save method with type step count.

```swift
guard HealthKitReporter.isHealthDataAvailable else { return }
let reporter = HealthKitReporter()
let types = [QuantityType.stepCount]
reporter.manager.requestAuthorization(
    toRead: types,
    toWrite: types
) { (success, error) in
    if success && error == nil {
        reporter.manager.preferredUnits(for: types) { (preferredUnits, error) in
            for preferredUnit in preferredUnits {
                //Do write steps
                let identifier = preferredUnit.identifier
                guard
                    identifier == QuantityType.stepCount.identifier
                else {
                    return
                }
                let now = Date()
                let quantity = Quantity(
                    identifier: identifier,
                    startTimestamp: now.addingTimeInterval(-60).timeIntervalSince1970,
                    endTimestamp: now.timeIntervalSince1970,
                    device: Device(
                        name: "Guy's iPhone",
                        manufacturer: "Guy",
                        model: "6.1.1",
                        hardwareVersion: "some_0",
                        firmwareVersion: "some_1",
                        softwareVersion: "some_2",
                        localIdentifier: "some_3",
                        udiDeviceIdentifier: "some_4"
                    ),
                    sourceRevision: SourceRevision(
                        source: Source(
                            name: "mySource",
                            bundleIdentifier: "com.kvs.hkreporter"
                        ),
                        version: "1.0.0",
                        productType: "CocoaPod",
                        systemVersion: "1.0.0.0",
                        operatingSystem: SourceRevision.OperatingSystem(
                            majorVersion: 1,
                            minorVersion: 1,
                            patchVersion: 1
                        )
                    ),
                    harmonized: Quantity.Harmonized(
                        value: 123.0,
                        unit: preferredUnit.unit,
                        metadata: nil
                    )
                )
                reporter.writer.save(sample: quantity) { (success, uuid, error) in
                    if let uuid = uuid {
                        print("saved \(uuid)")
                    } else {
                        print(error)
                    }
                }
            }
        }
    } else {
        print(error)
    }
}
```

HealthKit gives every stored sample its own `uuid`, which `save` reports. Updating, deleting and relating act on stored samples, looked up by that `uuid`: a payload read from HealthKit already carries it, `copyWith` and `make(from:)` keep it, and `copyWith(uuid:)` sets it on a payload you built yourself.

```swift
reporter.writer.save(sample: steps) { _, uuid, _ in
    guard let uuid = uuid else { return }
    reporter.writer.delete(sample: steps.copyWith(uuid: uuid)) { success, error in }
}
```

`save(samples:)` and `delete(samples:)` do the same for several samples at once; either all of them are stored or deleted, or none:

```swift
let walks = [morningSteps, eveningSteps]
reporter.writer.save(samples: walks) { success, uuids, error in
    let stored = zip(walks, uuids).map { $0.copyWith(uuid: $1) }
    reporter.writer.delete(samples: stored) { success, error in }
}
```

`addQuantity` / `addCategory` add new samples to a stored workout, and `unrelateWorkoutEffort` needs the stored effort sample. Deleted objects in anchored queries carry only their `uuid`, so match it against the samples you keep.

Hint: if you have trouble choosing a unit for a sample you want to save, call the manager's _preferredUnits_, which returns the units preferred for the current locale for each quantity type.

```swift
reporter.manager.preferredUnits(for: [.stepCount]) { (preferredUnits, error) in
    for preferredUnit in preferredUnits {
        print("\(preferredUnit.identifier) - \(preferredUnit.unit)")
    }
}
```

### Clinical records

Clinical health records need the Clinical Health Records entitlement. Check `supportsHealthRecords()` (iOS only) before reading:

```swift
if reporter.manager.supportsHealthRecords() {
    let query = try reporter.reader.clinicalRecordQuery(type: .immunizationRecord) { records, error in
        records.forEach { print($0.harmonized.displayName, $0.harmonized.fhirData ?? "") }
    }
    reporter.manager.executeQuery(query)
}
```

CDA documents (iOS only) arrive in batches until `done`; the user authorizes each document the first time it matches:

```swift
let query = try reporter.reader.cdaDocumentQuery { documents, done, error in
    documents.forEach { print($0.harmonized.title ?? "", $0.harmonized.custodianName ?? "") }
}
reporter.manager.executeQuery(query)
```

Verifiable records (SMART Health Cards, iOS only) don't need prior authorization; the system asks the user which records to share each time:

```swift
let query = reporter.reader.verifiableClinicalRecordQuery(
    recordTypes: ["https://smarthealth.cards#immunization"]
) { records, error in
    records.forEach { print($0.harmonized.itemNames) }
}
reporter.manager.executeQuery(query)
```

### Hearing, mental wellbeing and medications

Audiograms (Hz / dBHL), State of Mind (iOS 18), GAD-7 / PHQ-9 assessments (iOS 18) and medications (iOS 26) have their own types, payloads and queries:

```swift
let audiograms = try reporter.reader.audiogramQuery { audiograms, error in
    audiograms.forEach { print($0.harmonized.sensitivityPoints.map(\.frequency)) }
}
let moods = try reporter.reader.stateOfMindQuery { states, error in
    states.forEach { print($0.harmonized.valence, $0.harmonized.labels) }
}
let anxiety = try reporter.reader.scoredAssessmentQuery(type: .gad7) { assessments, error in
    assessments.forEach { print($0.harmonized.score ?? 0, $0.harmonized.risk ?? 0) }
}
[audiograms, moods, anxiety].forEach(reporter.manager.executeQuery)
```

Audiograms, states of mind and assessments can be saved with `writer.save(sample:completion:)`; HealthKit computes the valence classification, score and risk. Medications are read-only and need per-object authorization:

```swift
reporter.manager.requestPerObjectReadAuthorization(for: MedicationType.userAnnotatedMedication) { success, _ in
    let medications = reporter.reader.userAnnotatedMedicationQuery { medications, error in
        for medication in medications {
            // the concept identifier narrows the dose events to this medication
            let doses = try? reporter.reader.medicationDoseEventQuery(
                medicationConceptIdentifier: medication.medication.identifier
            ) { doses, _ in print(medication.medication.displayText, doses.count) }
            doses.map(reporter.manager.executeQuery)
        }
    }
    reporter.manager.executeQuery(medications)
}
```

### Vision prescriptions

Vision prescriptions (iOS 16+) need per-object read authorization: the user picks which prescriptions the app may read.
Lens powers are in diopters, angles in degrees, distances in millimeters and prism amounts in prism diopters. `dateIssuedTimestamp` and `expirationDateTimestamp` are seconds since 1970.

```swift
let reporter = HealthKitReporter()
reporter.manager.requestPerObjectReadAuthorization(
    for: VisionPrescriptionType.visionPrescription
) { success, error in
    guard success, error == nil else {
        return
    }
    do {
        let query = try reporter.reader.visionPrescriptionQuery { prescriptions, error in
            for prescription in prescriptions {
                print(prescription.harmonized.prescriptionType.detail, prescription.harmonized.rightEye?.sphere ?? 0)
            }
        }
        reporter.manager.executeQuery(query)
    } catch {
        print(error)
    }
}
```

Save a glasses or contacts prescription with `reporter.writer.save(sample:completion:)`; a prism must sit on the lens of the eye it names.

### Series

Read the individual quantities of quantity series samples, and write quantity or heartbeat series:

```swift
let query = try reporter.reader.quantitySeriesQuery(type: .stepCount, unit: "count") { values, error in
    values.forEach { print($0.value, $0.startTimestamp) }
}
reporter.manager.executeQuery(query)

reporter.writer.saveQuantitySeries(
    type: .stepCount,
    values: [QuantitySeriesValue(value: 12, unit: "count", startTimestamp: start, endTimestamp: start + 10)]
) { success, error in }
reporter.writer.saveHeartbeatSeries(heartbeatSeries) { success, error in }
```

### Attachments

Files attached to a stored sample (iOS 16+), addressed by the sample's type and uuid:

```swift
reporter.manager.attachments(forSampleOf: VisionPrescriptionType.visionPrescription, uuid: prescription.uuid) { attachments, error in
    for attachment in attachments {
        reporter.manager.attachmentData(
            forSampleOf: VisionPrescriptionType.visionPrescription,
            uuid: prescription.uuid,
            attachmentIdentifier: attachment.identifier
        ) { data, error in print(attachment.name, data?.count ?? 0) }
    }
}
```

`addAttachment(toSampleOf:uuid:name:contentType:url:metadata:completion:)` attaches a local file and `removeAttachment(fromSampleOf:uuid:attachmentIdentifier:completion:)` removes one.

### Workouts

On iOS 16+ a `Workout` carries `statistics` for every recorded quantity type and the `activities` of a multi-sport workout; the totals fall back to the statistics when HealthKit leaves the deprecated totals empty.

Save new workouts through `HKWorkoutBuilder`, optionally with samples and a route; the harmonized totals become samples for the types you don't pass:

```swift
reporter.writer.saveWorkout(workout, samples: heartRates, route: locations) { savedWorkout, error in
    print(savedWorkout?.uuid ?? "", error ?? "")
}
```

Read the routes of a stored workout, with their locations, by the workout's uuid (4.1.0+):

```swift
let query = try reporter.reader.workoutRouteQuery(workoutUUID: workout.uuid) { routes, error in
    routes.forEach { print($0.harmonized.count, $0.harmonized.routes.flatMap(\.locations).count) }
}
reporter.manager.executeQuery(query)
```

A malformed uuid throws `HealthKitError.invalidValue`; a uuid with no stored workout reports `HealthKitError.invalidIdentifier` in the handler.

Workout effort (iOS 18): read the effort samples related to workouts with `reader.workoutEffortRelationshipQuery`, and relate one with `writer.relateWorkoutEffort(_:toWorkout:activity:completion:)`.

Live workout sessions and Swift async/await variants are out of scope; see `docs/adr/0003-workout-and-query-scope.md`.

### Several types in one query

`QueryDescriptor` pairs a type with a predicate; sample, anchored and observer queries accept several of them:

```swift
let descriptors = [
    QueryDescriptor(type: QuantityType.stepCount),
    QueryDescriptor(type: CategoryType.sleepAnalysis, predicate: lastWeek)
]
let query = try reporter.reader.anchoredObjectQuery(descriptors: descriptors) { _, samples, deleted, anchor, error in
    print(samples.count, deleted.count)
}
reporter.manager.executeQuery(query)
```

## Observing Data

Create a <i>HealthKitReporter</i> instance.

Authorize desired types to read/write, like step count and sleep analysis.

You might create an App which will be called every time by HealthKit, and receive notifications, that some data was changed in HealthKit depending on frequency. But keep in mind that sometimes the desired frequency you set cannot be fulfilled by HealthKit.

Call the observation query method inside your AppDelegate's method. This will let Apple Health to send events even if the app is in background or wake up your app,  if it was previously put into "Not Running" state and execute the code provided inside **observerQuery** update handler.

Warning: to run **observerQuery** when the app is killed by the system, provide an additional capability **Background Mode** and select **Background fetch**

The update handler receives HealthKit's **completion**. Call it once the update is processed, on every path: HealthKit throttles background delivery when it isn't called, and may suspend the app if it is called before the fetch finishes. The three-argument update handler is still available and calls **completion** right after it returns.

Use reporter's **manager's** _executeQuery_ to execute the query. (Or _stopQuery_ to stop)

```swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    guard HealthKitReporter.isHealthDataAvailable else { return }
    let reporter = HealthKitReporter()
    let types: [SampleType] = [
        QuantityType.stepCount,
        CategoryType.sleepAnalysis
    ]
    reporter.manager.requestAuthorization(
        toRead: types,
        toWrite: types
    ) { (success, error) in
        if success && error == nil {
            for type in types {
                do {
                    let query = try reporter.observer.observerQuery(
                        type: type
                    ) { (query, identifier, error, completion) in
                        guard error == nil, let identifier = identifier else {
                            completion()
                            return
                        }
                        // fetch the new samples, then tell HealthKit the update is processed
                        print("updates for \(identifier)")
                        completion()
                    }
                    reporter.observer.enableBackgroundDelivery(
                        type: type,
                        frequency: .daily
                    ) { (success, error) in
                        if error == nil {
                            print("enabled")
                        }
                    }
                    reporter.manager.executeQuery(query)
                } catch {
                    print(error)
                }
            }
        }
    }
    return true
}
```

## Example

To run the example project, clone the repo and open `Example/HealthKitReporter.xcodeproj`.
Xcode resolves the library from the repository root as a local Swift package. Select your development team, since HealthKit needs the signed entitlements, even on the simulator. Without a team, the simulator also accepts an ad-hoc signed build: `xcodebuild build -project Example/HealthKitReporter.xcodeproj -scheme HealthKitReporter_Example -destination "platform=iOS Simulator,name=iPhone 17" CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM=`.

The app lists every public method of the reader, writer, observer and manager, grouped by area. Tap a row to run it; its result, live updates or error appear in the row. Live queries (observers, anchored updates, statistics collections) keep updating until **Stop live queries**.

- **Authorization** requests every type the library supports: read access for all sample types, characteristics and activity summaries; write access for every type whose `isWritable` is true. Clinical records have their own row, since they start Health's records flow, which needs an Apple Account; vision prescriptions and medications use per-object authorization rows.
- **Simulator data:** on the first launch in the simulator the app authorizes and then seeds 7 days of plausible samples for every writable type, through the library's own writer. Seeded samples carry an `HKMetadataKeyExternalUUID` starting with `hkr-seed-`; seeding runs once per day and type, and **Delete seeded data** removes only data this app wrote.
- **Read-only data** (ECGs, characteristics, activity summaries, clinical records, medications) can't be written by apps; heartbeat series and routes come from their own write demos, not from seeding. On the simulator, enter characteristics in the Health app's profile, add sample clinical records under Health › Browse › Health Records, and pair an Apple Watch simulator for watch-recorded data; on a device, record them with Apple Watch. Their rows show an empty result until then.
- **Watch companion:** **Start a run on the watch** calls `startWatchApp`, which launches the embedded watch app (`HealthKitReporterWatch`) on a paired Apple Watch or watch simulator. It runs the workout live and saves it on End; the **Workouts** row then shows it.

## Migrating to 4.0.0

4.0.0 removes HealthKit types from the public API and fixes several wrong outputs, so it changes code and JSON:

- queries return a `QueryHandle`, anchors are a `Codable` `Anchor`, and every `Query` typealias is gone;
- `save` reports the stored sample's `uuid`; `delete`, `addQuantity` / `addCategory` and `unrelateWorkoutEffort` act on the stored sample with the payload's `uuid`;
- metadata encodes as a flat JSON object, vision prescription dates are seconds, and non-finite numbers are `"Infinity"`, `"-Infinity"` and `"NaN"`.

Every removed or changed symbol, with its replacement, is listed in [ADR 0004](docs/adr/0004-contract-changes-for-the-next-major-release.md).

## Requirements

The library supports iOS 15 / watchOS 8 & above.

## Installation

### Swift Package Manager

To install it, simply add the following lines to your Package.swift file
(or just use the Package Manager from within XCode and reference this repo):

```swift
dependencies: [
    .package(url: "https://github.com/kvs-coder/HealthKitReporter.git", from: "4.1.0") // x-release-please-version
]
```

### CocoaPods

CocoaPods is no longer supported: CocoaPods trunk becomes read-only on December 2, 2026.
`3.1.0` is the last version published to CocoaPods and stays available there:

```ruby
pod 'HealthKitReporter', '3.1.0'
```

## Releasing

Releases are automated with [release-please](https://github.com/googleapis/release-please).
Commits on `master` follow [Conventional Commits](https://www.conventionalcommits.org):
`fix` bumps the patch, `feat` the minor, and `!` / `BREAKING CHANGE:` the major version.
release-please keeps a release PR open with the next version and its `CHANGELOG.md` entry;
merging it tags the release (`X.Y.Z`) and publishes a GitHub Release, which is the Swift Package Manager release.

## Author

Victor Kachalov, victorkachalov@gmail.com

## License

HealthKitReporter is available under the MIT license. See the LICENSE file for more info.

## Sponsorship
If you think that my repo helped you to solve the issues you struggle with, please don't be shy and sponsor :-)
