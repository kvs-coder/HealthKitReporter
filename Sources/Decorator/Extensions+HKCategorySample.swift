//
//  Extensions+HKCategorySample.swift
//  HealthKitReporter
//
//  Created by Victor on 15.09.20.
//

import HealthKit

extension HKCategorySample: Harmonizable {
    typealias Harmonized = Category.Harmonized

    func harmonize() throws -> Harmonized {
        let categoryValue = try describedValue(of: try categoryType.parsed())
        return Harmonized(
            value: value,
            description: categoryValue?.description ?? String(),
            detail: categoryValue?.detail ?? String(),
            metadata: metadata?.asMetadata
        )
    }

    // swiftlint:disable:next function_body_length
    private func describedValue(of type: CategoryType) throws -> CategoryValueDescribable? {
        switch type {
        case .sleepAnalysis:
            return HKCategoryValueSleepAnalysis(rawValue: value)
        case .intermenstrualBleeding,
             .mindfulSession,
             .highHeartRateEvent,
             .lowHeartRateEvent,
             .irregularHeartRhythmEvent,
             .toothbrushingEvent,
             .pregnancy,
             .lactation,
             .sexualActivity,
             .handwashingEvent,
             .persistentIntermenstrualBleeding,
             .prolongedMenstrualPeriods,
             .irregularMenstrualCycles,
             .infrequentMenstrualCycles,
             .sleepApneaEvent,
             .hypertensionEvent:
            return HKCategoryValue(rawValue: value)
        case .menstrualFlow:
            return HKCategoryValueMenstrualFlow(rawValue: value)
        case .ovulationTestResult:
            return HKCategoryValueOvulationTestResult(rawValue: value)
        case .cervicalMucusQuality:
            return HKCategoryValueCervicalMucusQuality(rawValue: value)
        case .appleStandHour:
            return HKCategoryValueAppleStandHour(rawValue: value)
        case .contraceptive:
            return HKCategoryValueContraceptive(rawValue: value)
        case .audioExposureEvent,
             .environmentalAudioExposureEvent:
            return HKCategoryValueEnvironmentalAudioExposureEvent(rawValue: value)
        case .headphoneAudioExposureEvent:
            return HKCategoryValueHeadphoneAudioExposureEvent(rawValue: value)
        case .lowCardioFitnessEvent:
            return HKCategoryValueLowCardioFitnessEvent(rawValue: value)
        case .appetiteChanges:
            return HKCategoryValueAppetiteChanges(rawValue: value)
        case .abdominalCramps,
             .acne,
             .bladderIncontinence,
             .bloating,
             .breastPain,
             .chestTightnessOrPain,
             .chills,
             .constipation,
             .coughing,
             .diarrhea,
             .dizziness,
             .drySkin,
             .fainting,
             .fatigue,
             .fever,
             .generalizedBodyAche,
             .hairLoss,
             .headache,
             .heartburn,
             .hotFlashes,
             .lossOfSmell,
             .lossOfTaste,
             .lowerBackPain,
             .memoryLapse,
             .nausea,
             .nightSweats,
             .pelvicPain,
             .rapidPoundingOrFlutteringHeartbeat,
             .runnyNose,
             .shortnessOfBreath,
             .sinusCongestion,
             .skippedHeartbeat,
             .soreThroat,
             .vaginalDryness,
             .vomiting,
             .wheezing:
            return HKCategoryValueSeverity(rawValue: value)
        case .moodChanges,
             .sleepChanges:
            return HKCategoryValuePresence(rawValue: value)
        case .pregnancyTestResult:
            return HKCategoryValuePregnancyTestResult(rawValue: value)
        case .progesteroneTestResult:
            return HKCategoryValueProgesteroneTestResult(rawValue: value)
        case .appleWalkingSteadinessEvent:
            return HKCategoryValueAppleWalkingSteadinessEvent(rawValue: value)
        case .bleedingAfterPregnancy,
             .bleedingDuringPregnancy:
            guard #available(iOS 18.0, *) else {
                throw HealthKitError.notAvailable(
                    "\(type) is not available for the current iOS"
                )
            }
            return HKCategoryValueVaginalBleeding(rawValue: value)
        }
    }
}
