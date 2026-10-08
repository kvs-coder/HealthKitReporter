//
//  Extensions+HKVisionPrescription.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 04.10.22.
//

import HealthKit

@available(iOS 16.0, *)
extension HKVisionPrescription: Harmonizable {
    typealias Harmonized = VisionPrescription.Harmonized

    func harmonize() throws -> Harmonized {
        let glasses = self as? HKGlassesPrescription
        let contacts = self as? HKContactsPrescription
        let rightEye: HKLensSpecification? = glasses?.rightEye ?? contacts?.rightEye
        let leftEye: HKLensSpecification? = glasses?.leftEye ?? contacts?.leftEye
        return Harmonized(
            dateIssuedTimestamp: dateIssued.timeIntervalSince1970,
            expirationDateTimestamp: expirationDate?.timeIntervalSince1970,
            prescriptionType: VisionPrescription.PrescriptionType(prescriptionType: prescriptionType),
            rightEye: rightEye.map(VisionPrescription.LensSpecification.init(lensSpecification:)),
            leftEye: leftEye.map(VisionPrescription.LensSpecification.init(lensSpecification:)),
            brand: contacts?.brand,
            metadata: metadata?.asMetadata
        )
    }
}
