//
//  VisionPrescriptionTests.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import XCTest
import HealthKit
import HealthKitReporter

@available(iOS 16.0, watchOS 9.0, *)
class VisionPrescriptionTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        warmUpHealthStore()
    }

    private var prescriptionTypeDictionary: [String: Any] {
        return [
            "id": 1,
            "detail": "Glasses"
        ]
    }
    private var prismDictionary: [String: Any] {
        return [
            "amount": 1.5,
            "angle": 90,
            "eye": 2
        ]
    }
    private var rightEyeDictionary: [String: Any] {
        return [
            "sphere": -1.25,
            "cylinder": -0.5,
            "axis": 180,
            "addPower": 1,
            "vertexDistance": 12,
            "prism": prismDictionary,
            "farPupillaryDistance": 32,
            "nearPupillaryDistance": 30
        ]
    }
    private var harmonizedDictionary: [String: Any] {
        return [
            "dateIssuedTimestamp": startTimestamp,
            "expirationDateTimestamp": endTimestamp,
            "prescriptionType": prescriptionTypeDictionary,
            "rightEye": rightEyeDictionary,
            "leftEye": ["sphere": -1],
            "metadata": [
                "HKWasUserEntered": true
            ]
        ]
    }
    private var dictionary: [String: Any] {
        return [
            "identifier": "HKVisionPrescriptionTypeIdentifier",
            "startTimestamp": startTimestamp,
            "endTimestamp": endTimestamp,
            "device": deviceDictionary,
            "sourceRevision": sourceRevisionDictionary,
            "harmonized": harmonizedDictionary
        ]
    }

    func testCreateFromDictionary() throws {
        let sut = try VisionPrescription.make(from: dictionary)
        assertVisionPrescription(sut)
    }
    func testCreateThenEncodeThenDecode() throws {
        let sut = try VisionPrescription.make(from: dictionary)
        let encoded = try sut.encoded()
        let decoded = try JSONDecoder().decode(
            VisionPrescription.self,
            from: try XCTUnwrap(encoded.data(using: .utf8))
        )
        XCTAssertEqual(decoded.uuid, sut.uuid)
        assertVisionPrescription(decoded)
    }
    func testCreateFromDictionaryWithoutOptionalFields() throws {
        var harmonized = harmonizedDictionary
        for key in ["expirationDateTimestamp", "rightEye", "leftEye", "metadata"] {
            harmonized.removeValue(forKey: key)
        }
        var dictionary = dictionary
        dictionary.removeValue(forKey: "device")
        dictionary["harmonized"] = harmonized
        let sut = try VisionPrescription.make(from: dictionary)
        XCTAssertNil(sut.device)
        XCTAssertNil(sut.harmonized.expirationDateTimestamp)
        XCTAssertNil(sut.harmonized.rightEye)
        XCTAssertNil(sut.harmonized.leftEye)
        XCTAssertNil(sut.harmonized.brand)
        XCTAssertNil(sut.harmonized.metadata)
    }
    func testCreateFromInvalidDictionary() throws {
        assertEachKeyIsRequired(
            ["identifier", "startTimestamp", "endTimestamp", "sourceRevision", "harmonized"],
            in: dictionary,
            make: VisionPrescription.make
        )
        assertEachKeyIsRequired(
            ["dateIssuedTimestamp", "prescriptionType"],
            in: harmonizedDictionary,
            make: VisionPrescription.Harmonized.make
        )
        assertEachKeyIsRequired(
            ["id", "detail"],
            in: prescriptionTypeDictionary,
            make: VisionPrescription.PrescriptionType.make
        )
        assertEachKeyIsRequired(
            ["sphere"],
            in: rightEyeDictionary,
            make: VisionPrescription.LensSpecification.make
        )
        assertEachKeyIsRequired(
            ["amount", "angle", "eye"],
            in: prismDictionary,
            make: VisionPrescription.Prism.make
        )
    }
    func testCollectFromArray() throws {
        let sut = try VisionPrescription.collect(from: [dictionary])
        XCTAssertEqual(sut.count, 1)
        assertVisionPrescription(sut[0])
        assertInvalidValue(try VisionPrescription.collect(from: [dictionary, "not a dictionary"]))
    }
    func testCopyWithNoArgumentsKeepsAllFields() throws {
        let sut = try VisionPrescription.make(from: dictionary)
        XCTAssertEqual(try json(sut.copyWith()), try json(sut))
        XCTAssertEqual(try json(sut.harmonized.copyWith()), try json(sut.harmonized))
    }
    func testCopyWithChangesOnlyGivenField() throws {
        let sut = try VisionPrescription.make(from: dictionary)
        let harmonized = sut.harmonized.copyWith(brand: "Acuvue")
        XCTAssertEqual(harmonized.brand, "Acuvue")
        XCTAssertEqual(try json(harmonized, excluding: ["brand"]), try json(sut.harmonized))
        let copy = sut.copyWith(endTimestamp: 1)
        XCTAssertEqual(copy.endTimestamp, 1)
        XCTAssertEqual(
            try json(copy, excluding: ["endTimestamp"]),
            try json(sut, excluding: ["endTimestamp"])
        )
    }
}
// MARK: - Factory
@available(iOS 16.0, watchOS 9.0, *)
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescriptionTests {
    func testSaveConvertsGlassesAndContactsBeforeReachingHealthKit() throws {
        let glasses = try VisionPrescription.make(from: dictionary)
        let contacts = glasses.copyWith(
            harmonized: glasses.harmonized.copyWith(
                prescriptionType: VisionPrescription.PrescriptionType(id: 2, detail: "Contacts"),
                rightEye: VisionPrescription.LensSpecification(sphere: -2, baseCurve: 8.6, diameter: 14.2),
                brand: "Acuvue"
            )
        )
        for sample in [glasses, contacts] {
            let error = try save(sample)
            XCTAssertEqual((error as NSError?)?.domain, HKErrorDomain)
        }
        let invalidType = glasses.copyWith(
            harmonized: glasses.harmonized.copyWith(
                prescriptionType: VisionPrescription.PrescriptionType(id: 99, detail: "Monocle")
            )
        )
        assertInvalidType(try { throw try XCTUnwrap(try save(invalidType)) }())
        let invalidEye = glasses.copyWith(
            harmonized: glasses.harmonized.copyWith(
                rightEye: VisionPrescription.LensSpecification(
                    sphere: -1,
                    prism: VisionPrescription.Prism(amount: 1, angle: 90, eye: 1)
                )
            )
        )
        assertInvalidValue(try { throw try XCTUnwrap(try save(invalidEye)) }())
    }
    func testRequestPerObjectReadAuthorizationWithInvalidType() throws {
        var status: (success: Bool, error: Error?)?
        HealthKitReporter().manager.requestPerObjectReadAuthorization(
            for: UnavailableSampleType.unavailable
        ) { success, error in
            status = (success, error)
        }
        let result = try XCTUnwrap(status)
        XCTAssertFalse(result.success)
        assertInvalidType(try { throw try XCTUnwrap(result.error) }())
    }

    private enum UnavailableSampleType: SampleType {
        case unavailable

        var identifier: String? {
            return nil
        }
    }

    private func assertRightEye(
        _ rightEye: VisionPrescription.LensSpecification?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let rightEye = rightEye else {
            XCTFail("Missing right eye", file: file, line: line)
            return
        }
        XCTAssertEqual(rightEye.sphere, -1.25, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rightEye.cylinder ?? 0, -0.5, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rightEye.axis ?? 0, 180, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rightEye.addPower ?? 0, 1, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rightEye.vertexDistance ?? 0, 12, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rightEye.farPupillaryDistance ?? 0, 32, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rightEye.nearPupillaryDistance ?? 0, 30, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rightEye.prism?.amount ?? 0, 1.5, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rightEye.prism?.angle ?? 0, 90, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rightEye.prism?.eye, 2, file: file, line: line)
        XCTAssertNil(rightEye.baseCurve, file: file, line: line)
        XCTAssertNil(rightEye.diameter, file: file, line: line)
    }
    private func assertVisionPrescription(
        _ sut: VisionPrescription,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.identifier, "HKVisionPrescriptionTypeIdentifier", file: file, line: line)
        XCTAssertEqual(sut.startTimestamp, 1626884800, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(sut.endTimestamp, 1626884860, accuracy: 0.001, file: file, line: line)
        assertDevice(sut.device, file: file, line: line)
        assertSourceRevision(sut.sourceRevision, file: file, line: line)
        XCTAssertEqual(
            sut.harmonized.dateIssuedTimestamp,
            1626884800,
            accuracy: 0.001,
            file: file,
            line: line
        )
        XCTAssertEqual(
            sut.harmonized.expirationDateTimestamp ?? 0,
            1626884860,
            accuracy: 0.001,
            file: file,
            line: line
        )
        XCTAssertEqual(sut.harmonized.prescriptionType.id, 1, file: file, line: line)
        XCTAssertEqual(sut.harmonized.prescriptionType.detail, "Glasses", file: file, line: line)
        assertRightEye(sut.harmonized.rightEye, file: file, line: line)
        XCTAssertEqual(sut.harmonized.leftEye?.sphere ?? 0, -1, accuracy: 0.001, file: file, line: line)
        XCTAssertNil(sut.harmonized.brand, file: file, line: line)
        XCTAssertEqual(sut.harmonized.metadata, ["HKWasUserEntered": true], file: file, line: line)
    }
}

// MARK: - Identity
@available(iOS 16.0, watchOS 9.0, *)
extension VisionPrescriptionTests {
    func testCreateFromDictionaryKeepsUUID() throws {
        try assertMakeKeepsUUID(from: dictionary, make: VisionPrescription.make)
    }
    func testCopyWithKeepsUUID() throws {
        let sut = try VisionPrescription.make(from: dictionary)
        XCTAssertEqual(sut.copyWith(startTimestamp: 1).uuid, sut.uuid)
    }
}
