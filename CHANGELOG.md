## [1.3.2] - 19.01.2021.

* Deprecate SampleQuery, use specific queries instead (Quantity, Category etc.)
* Added more QuantityType enum cases (iOS 14)

## [1.3.1] - 23.12.2020.

* Fix with HKActivitySummaryType identifier

## [1.3.0] - 08.12.2020.

* All reading and observer queries are returned as objects in order to let to stop them running
* Manager is now responsible for executing queries
* Most of the reading queries will throw an Error if provided type is not recognized by HK
* Electrocardiograms voltage measurement

## [1.2.6] - 24.11.2020.

* Workout Route series query
* CLLocation usage in Workout Route

## [1.2.5] - 23.11.2020.

* Dietery water add
* Fix with Source Revision cinstructor from map

## [1.2.4] - 23.11.2020.

* Timestamps wide usage for payload (Flutter)


## [1.2.3] - 18.11.2020.

* SampleTypes in appropriate requests
* Add Correlation


## [1.2.2] - 18.11.2020.

* Correlation fix
* Fix with SampleType
* Refactoring

## [1.2.1] - 15.11.2020.

* More public extensions for Flutter support

## [1.2.0] - 12.11.2020.

* Cross-platform support for Flutter
* ObjectType as an aggregation type for different types
* Public extensions

## [1.1.2] - 11.11.2020.

* Making error enum public

## [1.1.1] - 21.10.2020.

* Documentation

## [1.1.0] - 21.10.2020.

* Distinguish queries between different kind of types
* Making usage of preferred units as main strategy to write or read data

## [1.0.1] - 02.10.2020.

* Add change log

## [1.0.0] - 02.10.2020.

* Initial release. The HealthKitReporter library to make easy data reading and writing for HealthKit
