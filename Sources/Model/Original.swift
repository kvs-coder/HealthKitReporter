//
//  Writable.swift
//  HealthKitReporter
//
//  Created by Victor on 25.09.20.
//

import Foundation

protocol Original {
    associatedtype Object: NSObject

    func asOriginal() throws -> Object
}
