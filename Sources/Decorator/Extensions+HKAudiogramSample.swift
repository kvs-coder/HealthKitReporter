//
//  Extensions+HKAudiogramSample.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

extension HKAudiogramSample: Harmonizable {
    typealias Harmonized = Audiogram.Harmonized

    func harmonize() throws -> Harmonized {
        return Harmonized(
            sensitivityPoints: sensitivityPoints.map(\.harmonized),
            metadata: metadata?.asMetadata
        )
    }
}
