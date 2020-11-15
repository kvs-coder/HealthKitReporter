//
//  Device.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation
import HealthKit

public struct Device: Codable {
    public let name: String?
    public let manufacturer: String?
    public let model: String?
    public let hardwareVersion: String?
    public let firmwareVersion: String?
    public let softwareVersion: String?
    public let localIdentifier: String?
    public let udiDeviceIdentifier: String?

    init(device: HKDevice?) {
        self.name = device?.name
        self.manufacturer = device?.manufacturer
        self.model = device?.model
        self.hardwareVersion = device?.hardwareVersion
        self.firmwareVersion = device?.firmwareVersion
        self.softwareVersion = device?.softwareVersion
        self.localIdentifier = device?.localIdentifier
        self.udiDeviceIdentifier = device?.udiDeviceIdentifier
    }

    public init(
        name: String?,
        manufacturer: String?,
        model: String?,
        hardwareVersion: String?,
        firmwareVersion: String?,
        softwareVersion: String?,
        localIdentifier: String?,
        udiDeviceIdentifier: String?
    ) {
        self.name = name
        self.manufacturer = manufacturer
        self.model = model
        self.hardwareVersion = hardwareVersion
        self.firmwareVersion = firmwareVersion
        self.softwareVersion = softwareVersion
        self.localIdentifier = localIdentifier
        self.udiDeviceIdentifier = udiDeviceIdentifier
    }
}
// MARK: - Original
extension Device: Original {
    func asOriginal() -> HKDevice {
        return HKDevice(
            name: name,
            manufacturer: manufacturer,
            model: model,
            hardwareVersion: hardwareVersion,
            firmwareVersion: firmwareVersion,
            softwareVersion: softwareVersion,
            localIdentifier: localIdentifier,
            udiDeviceIdentifier: udiDeviceIdentifier
        )
    }
}
// MARK: - Payload
extension Device: Payload {
    public static func make(
        from dictionary: [String: Any]
    ) throws -> Device {
        return Device(
            name: dictionary["name"] as? String,
            manufacturer: dictionary["manufacturer"] as? String,
            model: dictionary["model"] as? String,
            hardwareVersion: dictionary["hardwareVersion"] as? String,
            firmwareVersion: dictionary["firmwareVersion"] as? String,
            softwareVersion: dictionary["softwareVersion"] as? String,
            localIdentifier: dictionary["localIdentifier"] as? String,
            udiDeviceIdentifier: dictionary["udiDeviceIdentifier"] as? String
        )
    }
}
