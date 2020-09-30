//
//  Device.swift
//  HealthKitReporter
//
//  Created by KVS on 25.09.20.
//

import Foundation
import HealthKit

public struct Device: Codable, Writable {
    public let name: String?
    public let manufacturer: String?
    public let model: String?
    public let hardwareVersion: String?
    public let firmwareVersion: String?
    public let softwareVersion: String?
    public let localIdentifier: String?
    public let udiDeviceIdentifier: String?

    public init(device: HKDevice?) {
        self.name = device?.name
        self.manufacturer = device?.manufacturer
        self.model = device?.model
        self.hardwareVersion = device?.hardwareVersion
        self.firmwareVersion = device?.firmwareVersion
        self.softwareVersion = device?.softwareVersion
        self.localIdentifier = device?.localIdentifier
        self.udiDeviceIdentifier = device?.udiDeviceIdentifier
    }

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
