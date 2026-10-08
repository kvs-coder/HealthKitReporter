//
//  Extensions+HKAudiogramSensitivityPoint.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

extension HKAudiogramSensitivityPoint {
    /// Sensitivities from the unmasked air conduction tests on iOS 18.1+, the per-ear values before
    var harmonized: Audiogram.SensitivityPoint {
        let decibel = HKUnit.decibelHearingLevel()
        let frequency = frequency.doubleValue(for: .hertz())
        guard #available(iOS 18.1, watchOS 11.1, *) else {
            return Audiogram.SensitivityPoint(
                frequency: frequency,
                leftEarSensitivity: leftEarSensitivity?.doubleValue(for: decibel),
                rightEarSensitivity: rightEarSensitivity?.doubleValue(for: decibel)
            )
        }
        let tests = tests.map {
            Audiogram.Test(
                sensitivity: $0.sensitivity.doubleValue(for: decibel),
                conductionType: $0.type.rawValue,
                masked: $0.masked,
                side: $0.side.rawValue
            )
        }
        let sensitivity: (HKAudiogramSensitivityTestSide) -> Double? = { side in
            tests.first { $0.side == side.rawValue && $0.conductionType == 0 && !$0.masked }?.sensitivity
        }
        return Audiogram.SensitivityPoint(
            frequency: frequency,
            leftEarSensitivity: sensitivity(.left),
            rightEarSensitivity: sensitivity(.right),
            tests: tests
        )
    }
}
