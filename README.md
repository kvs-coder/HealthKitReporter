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
* launcher
* observer

Every property is responsible for an appropriate part of HealthKit framework. Based from the naming, reader will handle every manipaulation regarding reading data and writer will handle everything related to writing data in HealthKit repository, observer will handle observations and will notify if anything was changes in HealthKit, launcher is responsible to laun a WatchApp you make.

If you want to read, write data or observe data changes, you always need to be sure that the data types are authorized to be read/written/observed. In that case reader and writer have authorization methods with completion block telling about the presentation of the authorization window. Notice that Apple Health Kit will show this window only once during the whole time app is installed on the device, in this case if some types were denied to be read or written, user should manullly allow this in Apple Health App.

### Reading Data
Create a <i>HealthKitReporter</i> instance.

Authorize deisred types to read, like step count.

If authorization was successfull (the authorization window was shown) call sample query with type step count.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    do {
        let reporter = try HealthKitReporter()
        reporter.reader.requestAuthorization(
            toRead: [.stepCount]) { (success, error) in
            if success && error == nil {
                reporter.reader.sampleQuery(type: .stepCount) { (results, error) in
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
            } else {
                print(error)
            }
        }
    } catch {
        print(error)
    }
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
