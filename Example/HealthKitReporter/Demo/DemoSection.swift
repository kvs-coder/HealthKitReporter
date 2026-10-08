//
//  DemoSection.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import UIKit

/// Group of demo rows, one per area of the library
enum DemoSection: Int, CaseIterable {
    case authorization
    case characteristics
    case read
    case statistics
    case series
    case records
    case wellbeing
    case write
    case observe
    case manager
    case seeding

    var title: String {
        switch self {
        case .authorization:
            return "Authorization"
        case .characteristics:
            return "Characteristics"
        case .read:
            return "Read"
        case .statistics:
            return "Statistics"
        case .series:
            return "Series"
        case .records:
            return "Health records"
        case .wellbeing:
            return "Wellbeing & medications"
        case .write:
            return "Write & delete"
        case .observe:
            return "Observe"
        case .manager:
            return "Manager"
        case .seeding:
            return "Simulator data"
        }
    }

    var symbol: String {
        switch self {
        case .authorization:
            return "lock.shield.fill"
        case .characteristics:
            return "person.text.rectangle.fill"
        case .read:
            return "book.fill"
        case .statistics:
            return "chart.bar.fill"
        case .series:
            return "waveform.path.ecg"
        case .records:
            return "cross.case.fill"
        case .wellbeing:
            return "brain.head.profile"
        case .write:
            return "square.and.pencil"
        case .observe:
            return "eye.fill"
        case .manager:
            return "gearshape.2.fill"
        case .seeding:
            return "leaf.fill"
        }
    }

    var tint: UIColor {
        switch self {
        case .authorization:
            return .systemIndigo
        case .characteristics:
            return .systemPurple
        case .read:
            return .systemBlue
        case .statistics:
            return .systemTeal
        case .series:
            return .systemRed
        case .records:
            return .systemBrown
        case .wellbeing:
            return .systemMint
        case .write:
            return .systemGreen
        case .observe:
            return .systemOrange
        case .manager:
            return .systemGray
        case .seeding:
            return .systemPink
        }
    }

    var rows: [DemoRow] {
        return DemoRow.allCases.filter { $0.section == self }
    }
}
