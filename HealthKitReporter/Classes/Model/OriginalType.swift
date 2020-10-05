//
//  OriginalType.swift
//  HealthKitReporter
//
//  Created by Florian on 05.10.20.
//

import Foundation

protocol OriginalType {
    associatedtype ObjectType

    var original: ObjectType? { get }
}
