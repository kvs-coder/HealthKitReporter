//
//  Writable.swift
//  HealthKitReporter
//
//  Created by KVS on 25.09.20.
//

import Foundation

protocol Writable {
    associatedtype Object: NSObject

    func asOriginal() throws -> Object
}
