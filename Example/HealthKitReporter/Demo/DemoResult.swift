//
//  DemoResult.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Foundation

/// What a demo row shows: nothing yet, a running call, its output or its error
enum DemoResult: Equatable {
    case idle
    case running
    case success(String)
    case failure(String)

    var text: String? {
        switch self {
        case .idle:
            return nil
        case .running:
            return "Running…"
        case .success(let text), .failure(let text):
            return text
        }
    }
}
