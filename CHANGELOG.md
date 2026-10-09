# Changelog

## [4.1.1] - 09.10.2026.


### Bug Fixes

* **decorator:** format and parse fixed-format dates with the POSIX locale ([95b4bed](https://github.com/kvs-coder/HealthKitReporter/commit/95b4bed61f86840d7b790e930535e539a39cc9da))
* **metadata:** express concentration, clinical and vision metadata quantities ([f045ed2](https://github.com/kvs-coder/HealthKitReporter/commit/f045ed289a4973e33896bedbf735f89de5698b2c))
* **payload:** reject input that can't be converted instead of dropping it ([16ba71f](https://github.com/kvs-coder/HealthKitReporter/commit/16ba71f8ec38dbaf5e50f0461af7083c536f238f))
* **payload:** report entries that fail to convert instead of skipping them ([2b14d97](https://github.com/kvs-coder/HealthKitReporter/commit/2b14d9753735c2e0d5cd3bf8be987715ae2a8621))
* **reader:** report samples that fail to parse instead of skipping them ([f8a8231](https://github.com/kvs-coder/HealthKitReporter/commit/f8a82314bd713ac2d5ac8b8f2356f821ad2cc0a2))

## [4.1.0] - 09.10.2026.


### Features

* **reader:** workout routes by workout uuid ([dbd8fae](https://github.com/kvs-coder/HealthKitReporter/commit/dbd8fae02d53bd7945fc1705bd8520ca7868e455))

## [4.0.0] - 08.10.2026.


### ⚠ BREAKING CHANGES

* [String: Any].asMetadata is internal; build Metadata with Metadata.make(from:) or its literals.
* workoutEffortRelationshipQuery throws. Corrupt anchor data throws invalidValue instead of restarting the query; unknown correlation type predicate identifiers throw invalidType; save(sample:) of a Workout with both swimming strokes and flights climbed completes with invalidValue.
* save(sample:completion:) completes with (success, uuid, error). Sample requires uuid and identifier; Statistics and WorkoutEvent no longer conform to Sample. delete, addQuantity / addCategory and unrelateWorkoutEffort act on the stored sample with the payload's uuid, so send the uuid back in dictionaries.
* QueryHandle replaces every query typealias (Query, SampleQuery, ObserverQuery, …) in reader return types, executeQuery/stopQuery and callbacks; Anchor is a Codable struct instead of HKQueryAnchor; ObjectType.original and the public collect(results:) factories are removed; samplesPredicate takes SamplePredicateOptions; HealthKit enums lose their description conformances. ADR 0004 lists every change and what the Flutter plugin must update.
* **decorators:** Workout.Harmonized.description, Electrocardiogram.Harmonized.classification and WorkoutEvent.Harmonized.description return the corrected strings. Consumers comparing against the misspelled values must update them.
* **vision:** VisionPrescription.Harmonized.dateIssuedTimestamp and expirationDateTimestamp are seconds since 1970 instead of milliseconds; divide old values by 1000. The Harmonized initializer gains rightEye, leftEye and brand.
* **metadata:** Metadata is a struct of Metadata.Value instead of the .string/.date/.double enum, Metadata.original is replaced by internal conversion, and the JSON shape changes from {"string": {"dictionary": {...}}} to a flat object with dates as {"timestamp": seconds since 1970} and quantities as {"value", "unit"}. Dictionary literals keep compiling. The Flutter plugin must read and send the flat shape.
* **encoding:** non-finite numbers in encoded() JSON change from "inf" / "-500.0" to "Infinity" / "-Infinity" / "NaN". Consumers that matched the old strings (or treated -500.0 as NaN) must parse the new ones, e.g. with double.parse in Dart.
* **category:** audioExposureEvent samples now harmonize with description 'HKCategoryValueEnvironmentalAudioExposureEvent' and detail 'Momentary Limit' (previously 'HKCategoryValueAudioExposureEvent' / 'Load Environment'); the public description/detail extension on HKCategoryValueAudioExposureEvent is removed.
* minimum deployment targets are now iOS 15 and watchOS 8; CocoaPods and Carthage are no longer supported (3.1.0 is the last CocoaPods release).

### Features

* **activity-summary:** move time, move mode, paused and current goals ([4f41672](https://github.com/kvs-coder/HealthKitReporter/commit/4f416723c74d0180a2d68ef4e96c77bb33a0c2ac))
* **api:** fix misspelled names and honour the device when adding samples to a workout ([3a39356](https://github.com/kvs-coder/HealthKitReporter/commit/3a39356db26d25bb11651ec8d35c16bfe0b1ba24))
* **attachments:** list, read, add and remove sample attachments ([f096069](https://github.com/kvs-coder/HealthKitReporter/commit/f0960699e8b3daed5a1f30ccb831043a01c098fe))
* **documents:** CDA documents and a watchOS-clean build ([38df0ea](https://github.com/kvs-coder/HealthKitReporter/commit/38df0ea57e13123fae2903fbc9a68fb0a062c259))
* every payload collects from arrays and reads any numeric type ([8086516](https://github.com/kvs-coder/HealthKitReporter/commit/80865162eeed337e24523272a642e4a182e43f13))
* **example:** MVVM demo of every public API with Combine, full authorization and seeding ([4b06766](https://github.com/kvs-coder/HealthKitReporter/commit/4b06766cd45e2f1cf33ff7b01dac7a6ce424dd15))
* **example:** watchOS companion app for startWatchApp ([5026cc2](https://github.com/kvs-coder/HealthKitReporter/commit/5026cc2a3af6ef6d7aad25cfe387b5428d6be850))
* **health-records:** clinical record query, coverage and clinical note types, verifiable records ([a413ab6](https://github.com/kvs-coder/HealthKitReporter/commit/a413ab65e80a6160827f4b88ae09485950194cdd))
* **manager:** authorization request status, earliest sample date and estimate recalibration ([c39fcee](https://github.com/kvs-coder/HealthKitReporter/commit/c39fcee0b4860c62b37ca3c37886c47b774c7dff))
* **metadata:** hold mixed metadata values and encode them as a flat object ([3024a18](https://github.com/kvs-coder/HealthKitReporter/commit/3024a185d47c2badfce5e145445a396661e297c0))
* **observer:** hand HealthKit's completion to the observer update handler ([cdaefbf](https://github.com/kvs-coder/HealthKitReporter/commit/cdaefbf76a6a3c22832c4e6a5ffe5f27099f4697))
* **queries:** read and observe several types in one query ([a14e05e](https://github.com/kvs-coder/HealthKitReporter/commit/a14e05e62ca4a6b2f93d53af304ed8dbef7c716f))
* save and delete several samples at once; consistent error callbacks ([faf785b](https://github.com/kvs-coder/HealthKitReporter/commit/faf785b7fe6839d64a1cf5d2dfb1356e6741e56d))
* **series:** read quantity series values and write quantity and heartbeat series ([d0451cc](https://github.com/kvs-coder/HealthKitReporter/commit/d0451ccb80dd37bc980aeb11b9356454885da0a7))
* SPM-only distribution with CI and release-please releases ([f4061f1](https://github.com/kvs-coder/HealthKitReporter/commit/f4061f1f3da57bff71f87bffa44530f4ada9ca6a))
* **statistics:** deliver statistics collections in batches ([b7ee23e](https://github.com/kvs-coder/HealthKitReporter/commit/b7ee23e2e5c9215c499cc75d32cf44e346cc2951))
* **statistics:** per-source statistics and data duration ([160f958](https://github.com/kvs-coder/HealthKitReporter/commit/160f95891a8884292f180da6000020bbeba8269e))
* **types:** add category types introduced in iOS 18 and 26.2 ([da11814](https://github.com/kvs-coder/HealthKitReporter/commit/da118149067a3fc325f8d02dde3ff129fe464644))
* **types:** add quantity types introduced in iOS 16-18 ([4e46b58](https://github.com/kvs-coder/HealthKitReporter/commit/4e46b58d50cde6e1fc3702b75869a520cdb6806c))
* **types:** audiograms, state of mind, GAD-7/PHQ-9 assessments and medications ([8807dd2](https://github.com/kvs-coder/HealthKitReporter/commit/8807dd2ccae6e70f90abf2ea341dcf8a171b4026))
* **vision:** complete VisionPrescription with lenses, prism, query, writing and per-object authorization ([c7c60c3](https://github.com/kvs-coder/HealthKitReporter/commit/c7c60c3b5a3aa292552a09113f7b6b8d55b4b35e))
* **workouts:** activities, statistics, builder-based saving and workout effort ([35524cc](https://github.com/kvs-coder/HealthKitReporter/commit/35524cc1627288dec56ff40aed5f2549671d142a))


### Bug Fixes

* act on stored samples by uuid and keep payload identity ([c2d32a7](https://github.com/kvs-coder/HealthKitReporter/commit/c2d32a7ee4edaa21523fbb16816481db9b98b68d))
* authorization accepts CDA documents and adds the types series require ([d203faf](https://github.com/kvs-coder/HealthKitReporter/commit/d203faf3b819ce9d259269868e093a5b58b9efe9))
* **category:** decode symptom samples with the severity value enum ([260a85f](https://github.com/kvs-coder/HealthKitReporter/commit/260a85faffada21610cb72b5897a5cd5490e8545))
* **category:** replace deprecated audio exposure HealthKit APIs ([373651d](https://github.com/kvs-coder/HealthKitReporter/commit/373651d2b9ef7d2d648eda2a3bee556923800a79))
* **category:** stop infinite recursion in category value descriptions ([62821a6](https://github.com/kvs-coder/HealthKitReporter/commit/62821a6a7f36e94fb9c9bf1730d5f6757d7796ba))
* **correlation:** keep mixed children and report child conversion errors ([f55180b](https://github.com/kvs-coder/HealthKitReporter/commit/f55180bf60fc1bd95df5bb997620f9e3b84f7850))
* **decorators:** correct misspelled workout, ECG and event descriptions ([be780a9](https://github.com/kvs-coder/HealthKitReporter/commit/be780a91a359b569bc7b0e84ec1c559037efbb78))
* **decorators:** describe unknown HealthKit enum cases instead of crashing ([411fdbd](https://github.com/kvs-coder/HealthKitReporter/commit/411fdbd833f09d4921f8ae80f1268ba047d368e6))
* **encoding:** write non-finite numbers as Infinity, -Infinity and NaN ([d541bb2](https://github.com/kvs-coder/HealthKitReporter/commit/d541bb26e2512bc2d9b226d22d08c85956e1610d))
* **example:** request clinical records separately so authorization works without an Apple Account ([3b2097d](https://github.com/kvs-coder/HealthKitReporter/commit/3b2097d369d475aac4f3589f477343ca9fdafb04))
* **payload:** skip invalid entries in collect(from:) and reject monitored anchored queries with a limit ([7d39927](https://github.com/kvs-coder/HealthKitReporter/commit/7d39927985e9ae79015691dc871dc6d74c6eaea7))
* report invalid authorization types and sample input instead of crashing ([f5fc2f3](https://github.com/kvs-coder/HealthKitReporter/commit/f5fc2f3890937d630e40350b68001f6236b2d8ad))
* **retriever:** serialize concurrent ECG, heartbeat and route results ([87c65a9](https://github.com/kvs-coder/HealthKitReporter/commit/87c65a9e495e7b05718ab6cbba10d54333dd791f))
* stop dropping data silently on read and write ([b8a9a50](https://github.com/kvs-coder/HealthKitReporter/commit/b8a9a504823a52084b22bfa309a4975ca72c76f1))
* **units:** read audio exposure in dBASPL and dietary water in mL ([d8f66d5](https://github.com/kvs-coder/HealthKitReporter/commit/d8f66d5518bbea149897598bd6bbcdecb100f554))
* validate units, convert statistics values and always complete writer calls ([fdbd2d6](https://github.com/kvs-coder/HealthKitReporter/commit/fdbd2d6273e542733e8263bd3be45a4dc7e54c2d))


### Reverts

* **payload:** keep collect(from:) throwing on invalid entries ([32cfaa3](https://github.com/kvs-coder/HealthKitReporter/commit/32cfaa3926eb5b5872565788b1544aa7d3638dcd))


### Code Refactoring

* stop leaking HealthKit types through the public API ([1484c24](https://github.com/kvs-coder/HealthKitReporter/commit/1484c249a8a439d49d030f791a1e3b0e2621f8b6))

## [3.1.0] - 08.01.2024.

* Added support for HKClinicalRecord

## [3.0.0] - 12.03.2023.

* Check for Health data availability
* CHanged the way of creating HKR instance

## [2.0.0] - 29.10.2022.

* Revamp metadata

## [1.7.0] - 29.10.2022.

* Add new iOS 16 types (also missing iOS 15 types)

## [1.6.9] - 27.05.2022.

* Add copyWith methods to Correlation

## [1.6.8] - 27.05.2022.

* Small fix with Correlation save in health repository

## [1.6.7] - 27.05.2022.

* Small fix with Correlation copyWith method

## [1.6.6] - 27.05.2022.

* Add saving Correlation samples

## [1.6.5] - 18.04.2022.

* ECG with Voltage measurements in one query on demand

## [1.6.4] - 17.04.2022.

* ECG with Voltage measurements in one query

## [1.6.3] - 16.04.2022.

* add from dictionary static factory for WorkoutRoute
* minor fixes in the code

## [1.6.2] - 23.10.2021.

* Fix timestamps bug
* add from dictionary static factory for HeartbeatSeries

## [1.6.1] - 15.10.2021.

* return HeartbeatSeries as a collection of samples, each has own collection of measurements

## [1.6.0] - 12.10.2021.

* heartbeatSeriesQuery changed as HeartbeatSeries now is a valid sample with a set of beat by beat measurements

## [1.5.3] - 05.09.2021.

* Sample app adjustments

## [1.5.2] - 05.09.2021.

* Extension of Category types, add detail key-value to DTO

## [1.5.1] - 04.09.2021.

* CustomStringConvertable for HK enum Types
* Workout and WorkoutEvent restructuring, add harmonized description instead of name and type property respectively

## [1.5.0] - 04.09.2021.

* Unit Tests for most of DTO Models
* WorkoutConfiguration bug fix for parsing
* WorkoutEventType name
* Parsing number values from incoming JSON dictionaries as NSNumber
* Fix the typos (HeartbeatSeries)

## [1.4.5] - 28.06.2021.

* Fix with minimum Operation System for iOS 10

## [1.4.4] - 27.05.2021.

* Swift package fix

## [1.4.3] - 02.04.2021.

* Add Workout names

## [1.4.2] - 12.03.2021.

* Fix Statistics sources

## [1.4.0] - 25.02.2021.

* iOS 9.0 support
* Carthage and Swift Package Manager support
* FIx with workout values
* Fix with UUID of Samples

## [1.3.6] - 10.02.2021.

* Remove redundant UUID paramater

## [1.3.5] - 10.02.2021.

* Fix issue with saving Workout

## [1.3.4] - 01.02.2021.

* Added UUID property for Wrappers of original HKObjectTypes

## [1.3.3] - 27.01.2021.

* Added more CategoryType enum cases (iOS 14)

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
