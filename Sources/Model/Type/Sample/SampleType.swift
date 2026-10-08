//
//  SampleType.swift
//  HealthKitReporter
//
//  Created by Victor on 18.11.20.
//

import Foundation

/// An **ObjectType** whose objects are samples
public protocol SampleType: ObjectType {}

/// Sample types HealthKit only computes or records itself; requesting write access to them raises
private let readOnlyIdentifiers: Set<String> = [
    "HKQuantityTypeIdentifierAppleExerciseTime",
    "HKQuantityTypeIdentifierAppleMoveTime",
    "HKQuantityTypeIdentifierAppleStandTime",
    "HKQuantityTypeIdentifierAppleWalkingSteadiness",
    "HKQuantityTypeIdentifierAppleSleepingWristTemperature",
    "HKQuantityTypeIdentifierAppleSleepingBreathingDisturbances",
    "HKQuantityTypeIdentifierAtrialFibrillationBurden",
    "HKQuantityTypeIdentifierNikeFuel",
    "HKQuantityTypeIdentifierWalkingAsymmetryPercentage",
    "HKQuantityTypeIdentifierWalkingHeartRateAverage",
    "HKCategoryTypeIdentifierAppleStandHour",
    "HKCategoryTypeIdentifierAppleWalkingSteadinessEvent",
    "HKCategoryTypeIdentifierAudioExposureEvent",
    "HKCategoryTypeIdentifierHeadphoneAudioExposureEvent",
    "HKCategoryTypeIdentifierHighHeartRateEvent",
    "HKCategoryTypeIdentifierHypertensionEvent",
    "HKCategoryTypeIdentifierInfrequentMenstrualCycles",
    "HKCategoryTypeIdentifierIrregularHeartRhythmEvent",
    "HKCategoryTypeIdentifierIrregularMenstrualCycles",
    "HKCategoryTypeIdentifierLowCardioFitnessEvent",
    "HKCategoryTypeIdentifierLowHeartRateEvent",
    "HKCategoryTypeIdentifierPersistentIntermenstrualBleeding",
    "HKCategoryTypeIdentifierProlongedMenstrualPeriods",
    "HKCategoryTypeIdentifierSleepApneaEvent",
    "HKDataTypeIdentifierElectrocardiogram"
]

public extension SampleType {
    /**
     Whether an app may request write access to the type.
     False for types HealthKit only computes or records itself, clinical records,
     correlations (authorize the types they correlate) and types unavailable on the running OS
     */
    var isWritable: Bool {
        guard let identifier = identifier else {
            return false
        }
        return !(self is CorrelationType)
            && !(self is ClinicalType)
            && !readOnlyIdentifiers.contains(identifier)
    }
}
