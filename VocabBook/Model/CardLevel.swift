//
//  CardLevel.swift
//  Vocab Book
//
//  Created by Oliver Brehm on 25.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import Foundation

enum CardLevel: UInt8, Codable, CaseIterable {
    case level0 = 0
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    case level5 = 5
    case level6 = 6

    // MARK: - Computed properties
    var nextLevel: CardLevel {
        CardLevel(rawValue: rawValue + 1) ?? .level6
    }

    var timeIntervalUntilDue: TimeInterval {
        let nDays: Int

        switch self {
        case .level0:
            nDays = 0
        case .level1:
            nDays = 1
        case .level2:
            nDays = 3
        case .level3:
            nDays = 6
        case .level4:
            nDays = 14
        case .level5:
            nDays = 30
        case .level6:
            nDays = 90
        }

        return Double(nDays) * 60 * 60 * 24
    }
}
