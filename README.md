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

You create a <i>HealthKitReporter</i> instance surrounded by do catch block. If Apple Health is not supported by the device (i.e. iPad) the catch block will be called.

The reporter instance contains several properties:
* reader
* writer
* manager
* observer

Every property is responsible for an appropriate part of HealthKit framework. Based from the naming, reader will handle every manipulation regarding reading data and writer will handle everything related to writing data in HealthKit repository, observer will handle observations and will notify if anything was changes in HealthKit, manager is responsible for the authorization of read/write types and launching a WatchApp you make.

If you want to read, write data or observe data changes, you always need to be sure that the data types are authorized to be read/written/observed. In that case manager has authorization method with completion block telling about the presentation of the authorization window. Notice that Apple Health Kit will show this window only once during the whole time app is installed on the device, in this case if some types were denied to be read or written, user should manually allow this in Apple Health App.

In examples below every operation is hapenning iside authorization block. It is recommended to do so, because if new type will be added, there will be thrown a permission exception. If you are sure that no new types will appear, you can call operations outside authorization block in your app, only if the type's data reading/writing permissions were granted.

### Reading Data
Create a <i>HealthKitReporter</i> instance.

Authorize desired types to read, like step count.

If authorization was successfull (the authorization window was shown) call sample query with type step count to create a **Query** object.

Use reporter's **manager's** _executeQuery_ to execute the query. (Or _stopQuery_ to stop)

```swift
do {
    let reporter = try HealthKitReporter()
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
} catch {
    print(error)
}
```

Here is a sample response for steps:

```json

{
  "sourceRevision" : {
    "productType" : "iPhone8,1",
    "systemVersion" : "14.0.0",
    "source" : {
      "name" : "Guy’s iPhone",
      "bundleIdentifier" : "com.apple.health.47609E07-490D-4E5F-8E68-9D8904E9BA08"
    },
    "version" : "14.0"
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

### Writing Data

***NOTE:*** *Clinical Records are read only, Health Kit does not allow writing any data to Clinical Records.*

Create a <i>HealthKitReporter</i> instance.

Authorize desired types to write, like step count.

You may call manager's <i>preferredUnits(for: )</i> function to pass units (for <b>Quantity Types</b>).

If authorization was successfull (the authorization window was shown) call save method with type step count.

```swift
do {
    let reporter = try HealthKitReporter()
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
                    reporter.writer.save(sample: quantity) { (success, error) in
                        if success && error == nil {
                            print("success")
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
} catch {
    print(error)
}
```

Hint: if you have trouble with choosing unit for an object you want to save, you can call a manager's function _preferredUnits_ which will return a dictionary with keys as identifiers of Quantitiy types and Units preferred for current localization.

```swift
reporter.manager.preferredUnits(for: [.stepCount]) { (dictionary, error) in
    for (identifier, unit) in dictionary {
        print("\(identifier) - \(unit)")
    }
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

## Observing Data

Create a <i>HealthKitReporter</i> instance.

Authorize desired types to read/write, like step count and sleep analysis.

You might create an App which will be called every time by HealthKit, and receive notifications, that some data was changed in HealthKit depending on frequency. But keep in mind that sometimes the desired frequency you set cannot be fulfilled by HealthKit.

Call the observation query method inside your AppDelegate's method. This will let Apple Health to send events even if the app is in background or wake up your app,  if it was previosly put into "Not Running" state and execute the code provided inside **observerQuery** update handler.

Warning: to run **observerQuery** when the app is killed by the system, provide an additional capability **Background Mode** and select **Background fetch**

The update handler receives HealthKit's **completion**. Call it once the update is processed, on every path: HealthKit throttles background delivery when it isn't called, and may suspend the app if it is called before the fetch finishes. The three-argument update handler is still available and calls **completion** right after it returns.

Use reporter's **manager's** _executeQuery_ to execute the query. (Or _stopQuery_ to stop)

```swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    do {
        let reporter = try HealthKitReporter()
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
    } catch {
        print(error)
    }
    return true
}
```

## Example

To run the example project, clone the repo and open `Example/HealthKitReporter.xcodeproj`.
Xcode resolves the library from the repository root as a local Swift package.

## Requirements

The library supports iOS 15 / watchOS 8 & above.

## Installation

### Swift Package Manager

To install it, simply add the following lines to your Package.swift file
(or just use the Package Manager from within XCode and reference this repo):

```swift
dependencies: [
    .package(url: "https://github.com/VictorKachalov/HealthKitReporter.git", from: "3.1.0") // x-release-please-version
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

## Sponsorhip
If you think that my repo helped you to solve the issues you struggle with, please don't be shy and sponsor :-)
