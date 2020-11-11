# HealthKitReporter

## About

A wrapper above HealthKit Apple's framework for data manipulations.
The library supports reading values from HealthKit repository and translating them to <i>Codable</i> models allowing to encode the result as a simple JSON payload.
In addition you can write your own HealthKit objects using <i>Codable</i> wrappers which will be translated to <i>HKObjectType</i> objects inside HealthKit repository.

## Start

### Preparation

At first in your app's entitlements select HealthKit. and in your app's info.plist file add permissions:

```xml
<key>NSHealthShareUsageDescription</key>
<string>WHY_YOU_NEED_TO_SHARE_DATA</string>
<key>NSHealthUpdateUsageDescription</key>
<string>WHY_YOU_NEED_TO_USE_DATA</string>
```

### Common usage

You create a <i>HealthKitReporter</i> instance surrounded by do catch block. If Apple Health is not supported by the device (i.e. iPad) the catch block will be called.

The reporter instance contains several properties:
* reader
* writer
* manager
* observer

Every property is responsible for an appropriate part of HealthKit framework. Based from the naming, reader will handle every manipulation regarding reading data and writer will handle everything related to writing data in HealthKit repository, observer will handle observations and will notify if anything was changes in HealthKit, manager is responsible for the authorization of read/write types and launching a WatchApp you make.

If you want to read, write data or observe data changes, you always need to be sure that the data types are authorized to be read/written/observed. In that case manager has authorization method with completion block telling about the presentation of the authorization window. Notice that Apple Health Kit will show this window only once during the whole time app is installed on the device, in this case if some types were denied to be read or written, user should manullly allow this in Apple Health App.

In examples below every operation is hapenning iside authorization block. It is recommended to do so, because if new type will be added, there will be thrown a permission exception. If you are sure that no new types will appear, you can call operations outside authorization block in your app, only if the type's data reading/writing permissions were granted.

### Reading Data
Create a <i>HealthKitReporter</i> instance.

Authorize deisred types to read, like step count.

If authorization was successfull (the authorization window was shown) call sample query with type step count.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    do {
        let reporter = try HealthKitReporter()
        let types = [QuantityType.stepCount]
        reporter.manager.requestAuthorization(
            toRead: types,
            toWrite: types
        ) { (success, error) in
            if success && error == nil {
                reporter.manager.preferredUnits(for: types) { (dict, error) in
                    if error == nil {
                        for (type, unit) in dict {
                            reporter.reader.quantityQuery(
                                type: type,
                                unit: unit
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

### Writing Data
Create a <i>HealthKitReporter</i> instance.

Authorize deisred types to write, like step count.

You may call manager's <i>preferredUnits(for: )</i> function to pass units (for <b>Quantity Types</b>).

If authorization was successfull (the authorization window was shown) call save method with type step count.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    do {
        let reporter = try HealthKitReporter()
        let types = [QuantityType.stepCount]
        reporter.manager.requestAuthorization(
            toRead: types,
            toWrite: types
        ) { (success, error) in
            if success && error == nil {
                reporter.manager.preferredUnits(for: types) { (dict, error) in
                    for (type, unit) in dict {
                        //Do write steps
                        guard
                            let identifier = type.identifier,
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
                            ), sourceRevision: SourceRevision(
                                source: Source(name: "mySource", bundleIdentifier: "com.kvs.hkreporter"),
                                version: "1.0.0",
                                productType: "CocoaPod",
                                systemVersion: "1.0.0.0"),
                            harmonized: Quantity.Harmonized(
                                value: 123.0,
                                unit: unit,
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

## Observing Data

Create a <i>HealthKitReporter</i> instance.

Authorize deisred types to write, like step count.

If authorization was successfull (the authorization window was shown) call save method with type step count.

Important to notice, if you want to enable background deliveries with notifications about new data in Health Kit repository, call the observation query method inside your AppDelegate's method

```swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    do {
        let reporter = try HealthKitReporter()
        let types = [QuantityType.stepCount]
        reporter.manager.requestAuthorization(
            toRead: types,
            toWrite: types
        ) { (success, error) in
            if success && error == nil {
                reporter.observer.observerQuery(type: .stepCount) { (identifier, error) in
                    if error == nil {
                        print("updates for \(identifier)")
                    }
                }
                reporter.observer.enableBackgroundDelivery(
                    type: .stepCount,
                    frequency: .daily
                ) { (success, error) in
                    if error == nil {
                        print("enabled")
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

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

The library supports iOS 12. 
Some features like HKHeartbeatSeries available only starting with iOS 13.0 and like HKElectrocardiogramm starting with iOS 14.0

## Installation

HealthKitReporter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HealthKitReporter'
```

## Author

Victor Kachalov, victorkachalov@gmail.com

## License

HealthKitReporter is available under the MIT license. See the LICENSE file for more info.
