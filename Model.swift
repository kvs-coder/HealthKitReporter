//
//  Model.swift
//  HealthKitReporter
//
//  Created by Florian on 14.09.20.
//

import Foundation

public struct Statistics: Codable {
    let identifier: String
    let value: Double
    let startDate: String?
    let endDate: String?
    let unit: String
}
public struct Sample: Codable {

}
public struct Characteristics: Codable {
    let biologicalSex: String
    let birthday: String?
    let bloodType: String
    let skinType: String
}
