//
//  VisionPrescription.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 04.10.22.
//

import HealthKit

/**
 Glasses or contacts prescription.
 Lens powers are in diopters (D), angles in degrees (deg), distances in millimeters (mm)
 and prism amounts in prism diopters (pD).
 */
@available(iOS 16.0, watchOS 9.0, *)
public struct VisionPrescription: Identifiable, Sample {
    /// **PrescriptionType** glasses or contacts
    public struct PrescriptionType: Codable {
        public let id: Int
        public let detail: String

        /// Creates the **PrescriptionType** from its fields
        public init(id: Int, detail: String) {
            self.id = id
            self.detail = detail
        }

        init(prescriptionType: HKVisionPrescriptionType) {
            self.id = Int(prescriptionType.rawValue)
            self.detail = prescriptionType.detail
        }
    }

    /// The value part of **VisionPrescription**, with its metadata
    public struct Harmonized: Codable {
        /// seconds since 1970
        public let dateIssuedTimestamp: Double
        /// seconds since 1970
        public let expirationDateTimestamp: Double?
        public let prescriptionType: PrescriptionType
        public let rightEye: LensSpecification?
        public let leftEye: LensSpecification?
        /// contacts brand
        public let brand: String?
        public let metadata: Metadata?

        /// Creates the **Harmonized** from its fields
        public init(
            dateIssuedTimestamp: Double,
            expirationDateTimestamp: Double?,
            prescriptionType: PrescriptionType,
            rightEye: LensSpecification?,
            leftEye: LensSpecification?,
            brand: String?,
            metadata: Metadata?
        ) {
            self.dateIssuedTimestamp = dateIssuedTimestamp
            self.expirationDateTimestamp = expirationDateTimestamp
            self.prescriptionType = prescriptionType
            self.rightEye = rightEye
            self.leftEye = leftEye
            self.brand = brand
            self.metadata = metadata
        }

        /// A copy with the given fields replaced; nil keeps the current value
        public func copyWith(
            dateIssuedTimestamp: Double? = nil,
            expirationDateTimestamp: Double? = nil,
            prescriptionType: PrescriptionType? = nil,
            rightEye: LensSpecification? = nil,
            leftEye: LensSpecification? = nil,
            brand: String? = nil,
            metadata: Metadata? = nil
        ) -> Harmonized {
            return Harmonized(
                dateIssuedTimestamp: dateIssuedTimestamp ?? self.dateIssuedTimestamp,
                expirationDateTimestamp: expirationDateTimestamp ?? self.expirationDateTimestamp,
                prescriptionType: prescriptionType ?? self.prescriptionType,
                rightEye: rightEye ?? self.rightEye,
                leftEye: leftEye ?? self.leftEye,
                brand: brand ?? self.brand,
                metadata: metadata ?? self.metadata
            )
        }
    }

    public let uuid: String
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: Harmonized

    /**
     Creates the payload. **uuid** names the stored sample; a new one by default,
     since HealthKit gives every saved sample its own
     */
    public init(
        uuid: String = UUID().uuidString,
        identifier: String,
        startTimestamp: Double,
        endTimestamp: Double,
        device: Device?,
        sourceRevision: SourceRevision,
        harmonized: Harmonized
    ) {
        self.uuid = uuid
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.harmonized = harmonized
    }

    init(visionPrescription: HKVisionPrescription) throws {
        self.uuid = visionPrescription.uuid.uuidString
        self.identifier = visionPrescription.sampleType.identifier
        self.startTimestamp = visionPrescription.startDate.timeIntervalSince1970
        self.endTimestamp = visionPrescription.endDate.timeIntervalSince1970
        self.device = Device(device: visionPrescription.device)
        self.sourceRevision = SourceRevision(sourceRevision: visionPrescription.sourceRevision)
        self.harmonized = try visionPrescription.harmonize()
    }

    /// A copy with the given fields replaced; nil keeps the current value, including the **uuid**
    public func copyWith(
        uuid: String? = nil,
        identifier: String? = nil,
        startTimestamp: Double? = nil,
        endTimestamp: Double? = nil,
        device: Device? = nil,
        sourceRevision: SourceRevision? = nil,
        harmonized: Harmonized? = nil
    ) -> VisionPrescription {
        return VisionPrescription(
            uuid: uuid ?? self.uuid,
            identifier: identifier ?? self.identifier,
            startTimestamp: startTimestamp ?? self.startTimestamp,
            endTimestamp: endTimestamp ?? self.endTimestamp,
            device: device ?? self.device,
            sourceRevision: sourceRevision ?? self.sourceRevision,
            harmonized: harmonized ?? self.harmonized
        )
    }
}
// MARK: - LensSpecification
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescription {
    /// Lens of one eye.
    /// Glasses use the vertex distance, prism and pupillary distances; contacts the base curve and diameter
    public struct LensSpecification: Codable {
        /// D
        public let sphere: Double
        /// D
        public let cylinder: Double?
        /// deg
        public let axis: Double?
        /// D
        public let addPower: Double?
        /// mm
        public let vertexDistance: Double?
        public let prism: Prism?
        /// mm
        public let farPupillaryDistance: Double?
        /// mm
        public let nearPupillaryDistance: Double?
        /// mm
        public let baseCurve: Double?
        /// mm
        public let diameter: Double?

        /// Creates the **LensSpecification** from its fields
        public init(
            sphere: Double,
            cylinder: Double? = nil,
            axis: Double? = nil,
            addPower: Double? = nil,
            vertexDistance: Double? = nil,
            prism: Prism? = nil,
            farPupillaryDistance: Double? = nil,
            nearPupillaryDistance: Double? = nil,
            baseCurve: Double? = nil,
            diameter: Double? = nil
        ) {
            self.sphere = sphere
            self.cylinder = cylinder
            self.axis = axis
            self.addPower = addPower
            self.vertexDistance = vertexDistance
            self.prism = prism
            self.farPupillaryDistance = farPupillaryDistance
            self.nearPupillaryDistance = nearPupillaryDistance
            self.baseCurve = baseCurve
            self.diameter = diameter
        }
    }
    /// Prism correcting double vision
    public struct Prism: Codable {
        /// pD
        public let amount: Double
        /// deg
        public let angle: Double
        /// 1 left, 2 right (**HKVisionEye**)
        public let eye: Int

        /// Creates the **Prism** from its fields
        public init(amount: Double, angle: Double, eye: Int) {
            self.amount = amount
            self.angle = angle
            self.eye = eye
        }
    }
}
// MARK: - Original
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescription: Original {
    func asOriginal() throws -> HKVisionPrescription {
        try startTimestamp.checkInterval(to: endTimestamp)
        let metadata = try harmonized.metadata?.asOriginal()
        let expirationDate = harmonized.expirationDateTimestamp?.asDate
        switch HKVisionPrescriptionType(rawValue: UInt(harmonized.prescriptionType.id)) {
        case .glasses:
            return HKGlassesPrescription(
                rightEyeSpecification: try harmonized.rightEye?.asGlassesOriginal(eye: .right),
                leftEyeSpecification: try harmonized.leftEye?.asGlassesOriginal(eye: .left),
                dateIssued: harmonized.dateIssuedTimestamp.asDate,
                expirationDate: expirationDate,
                device: device?.asOriginal(),
                metadata: metadata
            )
        case .contacts:
            return HKContactsPrescription(
                rightEyeSpecification: harmonized.rightEye?.asContactsOriginal(),
                leftEyeSpecification: harmonized.leftEye?.asContactsOriginal(),
                brand: harmonized.brand ?? String(),
                dateIssued: harmonized.dateIssuedTimestamp.asDate,
                expirationDate: expirationDate,
                device: device?.asOriginal(),
                metadata: metadata
            )
        default:
            throw HealthKitError.invalidType(
                "Vision prescription type: \(harmonized.prescriptionType.id) could not be formatted"
            )
        }
    }
}
// MARK: - LensSpecification: Original
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescription.LensSpecification {
    init(lensSpecification: HKLensSpecification) {
        let glasses = lensSpecification as? HKGlassesLensSpecification
        let contacts = lensSpecification as? HKContactsLensSpecification
        self.init(
            sphere: lensSpecification.sphere.doubleValue(for: .diopter()),
            cylinder: lensSpecification.cylinder?.doubleValue(for: .diopter()),
            axis: lensSpecification.axis?.doubleValue(for: .degreeAngle()),
            addPower: lensSpecification.addPower?.doubleValue(for: .diopter()),
            vertexDistance: glasses?.vertexDistance?.doubleValue(for: .meterUnit(with: .milli)),
            prism: glasses?.prism.map(VisionPrescription.Prism.init(prism:)),
            farPupillaryDistance: glasses?.farPupillaryDistance?.doubleValue(for: .meterUnit(with: .milli)),
            nearPupillaryDistance: glasses?.nearPupillaryDistance?.doubleValue(for: .meterUnit(with: .milli)),
            baseCurve: contacts?.baseCurve?.doubleValue(for: .meterUnit(with: .milli)),
            diameter: contacts?.diameter?.doubleValue(for: .meterUnit(with: .milli))
        )
    }

    func asGlassesOriginal(eye: HKVisionEye) throws -> HKGlassesLensSpecification {
        let millimeter = HKUnit.meterUnit(with: .milli)
        return HKGlassesLensSpecification(
            sphere: HKQuantity(unit: .diopter(), doubleValue: sphere),
            cylinder: cylinder.map { HKQuantity(unit: .diopter(), doubleValue: $0) },
            axis: axis.map { HKQuantity(unit: .degreeAngle(), doubleValue: $0) },
            addPower: addPower.map { HKQuantity(unit: .diopter(), doubleValue: $0) },
            vertexDistance: vertexDistance.map { HKQuantity(unit: millimeter, doubleValue: $0) },
            prism: try prism?.asOriginal(of: eye),
            farPupillaryDistance: farPupillaryDistance.map { HKQuantity(unit: millimeter, doubleValue: $0) },
            nearPupillaryDistance: nearPupillaryDistance.map { HKQuantity(unit: millimeter, doubleValue: $0) }
        )
    }
    func asContactsOriginal() -> HKContactsLensSpecification {
        let millimeter = HKUnit.meterUnit(with: .milli)
        return HKContactsLensSpecification(
            sphere: HKQuantity(unit: .diopter(), doubleValue: sphere),
            cylinder: cylinder.map { HKQuantity(unit: .diopter(), doubleValue: $0) },
            axis: axis.map { HKQuantity(unit: .degreeAngle(), doubleValue: $0) },
            addPower: addPower.map { HKQuantity(unit: .diopter(), doubleValue: $0) },
            baseCurve: baseCurve.map { HKQuantity(unit: millimeter, doubleValue: $0) },
            diameter: diameter.map { HKQuantity(unit: millimeter, doubleValue: $0) }
        )
    }
}
// MARK: - Prism: Original
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescription.Prism {
    init(prism: HKVisionPrism) {
        self.init(
            amount: prism.amount.doubleValue(for: .prismDiopter()),
            angle: prism.angle.doubleValue(for: .degreeAngle()),
            eye: prism.eye.rawValue
        )
    }

    /// HealthKit rejects a prism whose eye differs from the lens it belongs to
    func asOriginal(of lensEye: HKVisionEye) throws -> HKVisionPrism {
        guard eye == lensEye.rawValue else {
            throw HealthKitError.invalidValue("Prism eye \(eye) does not match lens eye \(lensEye.rawValue)")
        }
        return HKVisionPrism(
            amount: HKQuantity(unit: .prismDiopter(), doubleValue: amount),
            angle: HKQuantity(unit: .degreeAngle(), doubleValue: angle),
            eye: lensEye
        )
    }
}
// MARK: - Payload
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescription: Payload {
    /**
     Makes a **VisionPrescription** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> VisionPrescription {
        guard
            let identifier = dictionary["identifier"] as? String,
            let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
            let endTimestamp = dictionary["endTimestamp"] as? NSNumber,
            let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
            let harmonized = dictionary["harmonized"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let device = dictionary["device"] as? [String: Any]
        return VisionPrescription(
            uuid: dictionary.payloadUUID,
            identifier: identifier,
            startTimestamp: Double(truncating: startTimestamp),
            endTimestamp: Double(truncating: endTimestamp),
            device: try device.map(Device.make),
            sourceRevision: try SourceRevision.make(from: sourceRevision),
            harmonized: try Harmonized.make(from: harmonized)
        )
    }
}
// MARK: - Factory
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescription {
    static func collect(results: [HKSample]) -> [VisionPrescription] {
        return results
            .compactMap { $0 as? HKVisionPrescription }
            .compactMap { try? VisionPrescription(visionPrescription: $0) }
    }
}
// MARK: - Harmonized: Payload
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescription.Harmonized: Payload {
    /**
     Makes a **VisionPrescription.Harmonized** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> VisionPrescription.Harmonized {
        guard
            let dateIssuedTimestamp = dictionary["dateIssuedTimestamp"] as? NSNumber,
            let prescriptionType = dictionary["prescriptionType"] as? [String: Any]
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let expirationDateTimestamp = dictionary["expirationDateTimestamp"] as? NSNumber
        let rightEye = dictionary["rightEye"] as? [String: Any]
        let leftEye = dictionary["leftEye"] as? [String: Any]
        let metadata = dictionary["metadata"] as? [String: Any]
        return VisionPrescription.Harmonized(
            dateIssuedTimestamp: Double(truncating: dateIssuedTimestamp),
            expirationDateTimestamp: expirationDateTimestamp.map { Double(truncating: $0) },
            prescriptionType: try VisionPrescription.PrescriptionType.make(from: prescriptionType),
            rightEye: try rightEye.map(VisionPrescription.LensSpecification.make),
            leftEye: try leftEye.map(VisionPrescription.LensSpecification.make),
            brand: dictionary["brand"] as? String,
            metadata: try metadata.map(Metadata.make)
        )
    }
}
// MARK: - PrescriptionType: Payload
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescription.PrescriptionType: Payload {
    /**
     Makes a **VisionPrescription.PrescriptionType** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> VisionPrescription.PrescriptionType {
        guard
            let id = dictionary["id"] as? NSNumber,
            let detail = dictionary["detail"] as? String
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return VisionPrescription.PrescriptionType(id: id.intValue, detail: detail)
    }
}
// MARK: - LensSpecification: Payload
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescription.LensSpecification: Payload {
    /**
     Makes a **VisionPrescription.LensSpecification** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> VisionPrescription.LensSpecification {
        guard let sphere = dictionary["sphere"] as? NSNumber else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        let number: (String) -> Double? = { key in
            (dictionary[key] as? NSNumber).map { Double(truncating: $0) }
        }
        let prism = dictionary["prism"] as? [String: Any]
        return VisionPrescription.LensSpecification(
            sphere: Double(truncating: sphere),
            cylinder: number("cylinder"),
            axis: number("axis"),
            addPower: number("addPower"),
            vertexDistance: number("vertexDistance"),
            prism: try prism.map(VisionPrescription.Prism.make),
            farPupillaryDistance: number("farPupillaryDistance"),
            nearPupillaryDistance: number("nearPupillaryDistance"),
            baseCurve: number("baseCurve"),
            diameter: number("diameter")
        )
    }
}
// MARK: - Prism: Payload
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescription.Prism: Payload {
    /**
     Makes a **VisionPrescription.Prism** from a dictionary with the keys of its JSON encoding.
     - Parameter dictionary: **[String: Any]** dictionary
     - Throws: HealthKitError.invalidValue when a required key is missing or malformed
     */
    public static func make(from dictionary: [String: Any]) throws -> VisionPrescription.Prism {
        guard
            let amount = dictionary["amount"] as? NSNumber,
            let angle = dictionary["angle"] as? NSNumber,
            let eye = dictionary["eye"] as? NSNumber
        else {
            throw HealthKitError.invalidValue("Invalid dictionary: \(dictionary)")
        }
        return VisionPrescription.Prism(
            amount: Double(truncating: amount),
            angle: Double(truncating: angle),
            eye: eye.intValue
        )
    }
}
